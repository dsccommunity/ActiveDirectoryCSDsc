<#
    Suppress this PSSA message because we need to allow credentials to be
    set when running the tests.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

BeforeDiscovery {
    $script:dscModuleName = 'ActiveDirectoryCSDsc'
    $script:dscResourceName = 'DSC_AdcsEnrollmentPolicyWebService'

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
}

BeforeAll {
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

    # Ensure that the tests can be performed on this computer
    $skipIntegrationTests = $false

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

    # Integration tests can't be performed on this computer
    if ($skipIntegrationTests)
    {
        return
    }

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

Describe "$($script:dscResourceName) integration test" {
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
