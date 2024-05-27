<#
    Suppress this PSSA message because we need to allow credentials to be
    set when running the tests.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }

    <#
        Need to define that variables here to be used in the Pester Discover to
        build the ForEach-blocks.
    #>
    $script:dscModuleName = 'ActiveDirectoryCSDsc'
    $script:dscResourceFriendlyName = 'AdcsEnrollmentPolicyWebService'
    $script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

    # Ensure that the tests can be performed on this computer
    $script:skipIntegrationTests = $false

    if (-not (Test-WindowsFeature -Name 'ADCS-Enroll-Web-Pol'))
    {
        Write-Warning -Message 'Skipping integration tests for AdcsEnrollmentPolicyWebService because the feature ADCS-Enroll-Web-Pol is not installed.'
        $skipIntegrationTests = $true
    }

    if ([System.String]::IsNullOrEmpty($ENV:USERDNSDOMAIN))
    {
        Write-Warning -Message 'Skipping integration tests for AdcsEnrollmentPolicyWebService because it must be run on a domain joined server.'
        $skipIntegrationTests = $true
    }
}

BeforeAll {
    $script:dscModuleName = 'ActiveDirectoryCSDsc'
    $script:dscResourceFriendlyName = 'AdcsEnrollmentPolicyWebService'
    $script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"


    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Integration'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

    <#
        IMPORTANT: To run these tests requires a domain admin account to be
        available on the machine running the tests that can be used to install the
        ADCS component being tested. Please change the following values to the
        credentials that are set up for this purpose.

        These tests can not be run on AppVeyor because it requires a domain joined
        machine.
    #>
    $script:adminUsername = "$($env:USERDNSDOMAIN)\Administrator"
    $script:adminPassword = ConvertTo-SecureString -String 'NotPass12!' -AsPlainText -Force

    # Get the Administrator credential
    $script:adminCredential = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList ($script:adminUsername, $script:AdminPassword)

    # Create an SSL certificate to be used for the Web Service
    $script:certificate = New-SelfSignedCertificate `
        -DnsName $ENV:ComputerName `
        -CertStoreLocation Cert:\LocalMachine\My
}

AfterAll {
    # Remove the SSL certificate created for the Web Service
    if ($certificate)
    {
        $null = Remove-Item `
            -Path $certificate.PSPath `
            -Force
    }

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe "$($script:dscResourceName) integration test" -Skip:$skipIntegrationTests {
    BeforeDiscovery {
        # These are the test cases to run integration tests for
        $script:testAdcsEnrollmentPolicyWebServiceTestCases = @(
            @{
                AuthenticationType = 'Certificate'
                KeyBasedRenewal    = $false
            },
            @{
                AuthenticationType = 'Certificate'
                KeyBasedRenewal    = $true
            },
            @{
                AuthenticationType = 'Kerberos'
                KeyBasedRenewal    = $false
            },
            @{
                AuthenticationType = 'UserName'
                KeyBasedRenewal    = $false
            },
            @{
                AuthenticationType = 'UserName'
                KeyBasedRenewal    = $true
            }
        )
    }

    BeforeAll {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).Config.ps1"
        . $configFile
    }

    Context 'Install ADCS Enrollment Policy Web Service for AuthenticationType <AuthenticationType> and KeyBasedRenewal <KeyBasedRenewal>' -ForEach $testAdcsEnrollmentPolicyWebServiceTestCases {
        It 'Should compile and apply the MOF without throwing' {
            {
                $ConfigData = @{
                    AllNodes = @(
                        @{
                            NodeName                    = 'localhost'
                            AuthenticationType          = $AuthenticationType
                            SslCertThumbprint           = $certificate.Thumbprint
                            Credential                  = $script:adminCredential
                            KeyBasedRenewal             = $KeyBasedRenewal
                            Ensure                      = 'Present'
                            PsDscAllowPlainTextPassword = $true
                        }
                    )
                }

                & "$($script:dscResourceName)_Config" `
                    -OutputPath $TestDrive `
                    -ConfigurationData $ConfigData

                Start-DscConfiguration `
                    -Path $TestDrive `
                    -ComputerName localhost `
                    -Wait `
                    -Verbose `
                    -Force `
                    -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {
                $_.ConfigurationName -eq "$($script:dscResourceName)_Config"
            }
            $current.Ensure | Should -Be 'Present'
        }
    }

    Context 'Uninstall ADCS Enrollment Policy Web Service for AuthenticationType <AuthenticationType> and KeyBasedRenewal <KeyBasedRenewal>' -ForEach $testAdcsEnrollmentPolicyWebServiceTestCases {
        It 'Should compile and apply the MOF without throwing' {
            {
                $ConfigData = @{
                    AllNodes = @(
                        @{
                            NodeName                    = 'localhost'
                            AuthenticationType          = $AuthenticationType
                            SslCertThumbprint           = $certificate.Thumbprint
                            Credential                  = $script:adminCredential
                            KeyBasedRenewal             = $KeyBasedRenewal
                            Ensure                      = 'Absent'
                            PsDscAllowPlainTextPassword = $true
                        }
                    )
                }

                & "$($script:dscResourceName)_Config" `
                    -OutputPath $TestDrive `
                    -ConfigurationData $ConfigData `
                    -ErrorAction Stop

                Start-DscConfiguration `
                    -Path $TestDrive `
                    -ComputerName localhost `
                    -Wait `
                    -Verbose `
                    -Force `
                    -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {
                $_.ConfigurationName -eq "$($script:dscResourceName)_Config"
            }
            $current.Ensure | Should -Be 'Absent'
        }
    }
}
