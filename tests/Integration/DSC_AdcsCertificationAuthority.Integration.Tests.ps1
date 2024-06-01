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
    $script:dscResourceFriendlyName = 'AdcsCertificationAuthority'
    $script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

    # Ensure that the tests can be performed on this computer
    $script:skipIntegrationTests = $false

    # Ensure that the tests can be performed on this computer
    if (-not (Test-WindowsFeature -Name 'ADCS-Cert-Authority'))
    {
        Write-Warning -Message 'Skipping integration tests for AdcsCertificationAuthority because the feature ADCS-Cert-Authority is not installed.'
        $skipIntegrationTests = $true
    }
}

BeforeAll {
    $script:dscModuleName = 'ActiveDirectoryCSDsc'
    $script:dscResourceFriendlyName = 'AdcsCertificationAuthority'
    $script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Integration'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

    <#
        IMPORTANT: To run these tests requires a local Administrator account to be
        available on the machine running the tests that can be used to install the
        ADCS component being tested. This account will be created automatically for
        the tests and removed afterward.

        When these tests are run on Azure DevOps, ADCS-Cert-Authority will be installed
        and a new Administrator account will be created that uses credentials that
        match the ones following.
    #>
    $script:adminUsername = 'AdcsAdminTest'
    $script:adminPassword = ConvertTo-SecureString -String 'NotPass12!' -AsPlainText -Force

    # Create a new Local User in the administrators group
    $script:adminCredential = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList ($script:adminUsername, $script:adminPassword)
    New-LocalUserInAdministratorsGroup -Username $script:adminUsername -Password $script:adminPassword
}

AfterAll {
    Remove-LocalUser -Name $script:adminUsername -ErrorAction SilentlyContinue
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe "$($script:dscResourceName)_Install_Integration" -Skip:$skipIntegrationTests {
    BeforeAll {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName)_Install.Config.ps1"
        . $configFile
    }

    Context 'Install ADCS Certification Authority' {
        BeforeAll {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                    = 'localhost'
                        AdminCred                   = $script:adminCredential
                        PsDscAllowPlainTextPassword = $true
                    }
                )
            }
        }

        It 'Should compile and apply the MOF without throwing' {
            {
                & "$($script:dscResourceName)_Install_Config" `
                    -OutputPath $TestDrive `
                    -ConfigurationData $configData

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
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq "$($script:dscResourceName)_Install_Config"
            }
            $current.Ensure | Should -Be 'Present'
        }
    }
}

Describe 'DSC_AdcsCertificationAuthoritySettings_Integration' -Skip:$skipIntegrationTests {
    Context 'Configure ADCS Certification Authority Settings' {
        BeforeAll {
            $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName)Settings.config.ps1"
            . $configFile -Verbose -ErrorAction Stop

            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                    = 'localhost'
                        PsDscAllowPlainTextPassword = $true
                        CACertPublicationURLs       = @(
                            '1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt'
                            '2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11'
                            '2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt'
                        )
                        CRLPublicationURLs          = @(
                            '65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl'
                            '79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10'
                            '6:http://pki.contoso.com/CertEnroll/%3%8%9.crl'
                        )
                        CRLOverlapUnits             = 8
                        CRLOverlapPeriod            = 'Hours'
                        CRLPeriodUnits              = 1
                        CRLPeriod                   = 'Months'
                        ValidityPeriodUnits         = 10
                        ValidityPeriod              = 'Years'
                        DSConfigDN                  = 'CN=Configuration,DC=CONTOSO,DC=COM'
                        DSDomainDN                  = 'DC=CONTOSO,DC=COM'
                        AuditFilter                 = @(
                            'StartAndStopADCS'
                            'BackupAndRestoreCADatabase'
                            'IssueAndManageCertificateRequests'
                            'RevokeCertificatesAndPublishCRLs'
                            'ChangeCASecuritySettings'
                            'StoreAndRetrieveArchivedKeys'
                            'ChangeCAConfiguration'
                        )
                    }
                )
            }
        }


        It 'Should compile and apply the MOF without throwing' {
            {
                & 'DSC_AdcsCertificationAuthoritySettings_Config' `
                    -OutputPath $TestDrive `
                    -ConfigurationData $configData

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
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq 'DSC_AdcsCertificationAuthoritySettings_Config'
            }
            $current.CACertPublicationURLs | Should -BeExactly $configData.AllNodes[0].CACertPublicationURLs
            $current.CRLPublicationURLs | Should -BeExactly $configData.AllNodes[0].CRLPublicationURLs
            $current.CRLOverlapUnits | Should -BeExactly $configData.AllNodes[0].CRLOverlapUnits
            $current.CRLOverlapPeriod | Should -BeExactly $configData.AllNodes[0].CRLOverlapPeriod
            $current.CRLPeriodUnits | Should -BeExactly $configData.AllNodes[0].CRLPeriodUnits
            $current.CRLPeriod | Should -BeExactly $configData.AllNodes[0].CRLPeriod
            $current.ValidityPeriodUnits | Should -BeExactly $configData.AllNodes[0].ValidityPeriodUnits
            $current.ValidityPeriod | Should -BeExactly $configData.AllNodes[0].ValidityPeriod
            $current.DSConfigDN | Should -BeExactly $configData.AllNodes[0].DSConfigDN
            $current.DSDomainDN | Should -BeExactly $configData.AllNodes[0].DSDomainDN
            $current.AuditFilter | Should -BeExactly $configData.AllNodes[0].AuditFilter
        }
    }
}

Describe 'DSC_AdcsAuthorityInformationAccess_Integration' -Skip:$skipIntegrationTests {
    BeforeAll {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath 'DSC_AdcsAuthorityInformationAccess.config.ps1'
        . $configFile -Verbose -ErrorAction Stop
    }

    Context 'Set ADCS Certification Authority Authority Information Access' {
        BeforeAll {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName            = 'localhost'
                        AiaUri              = @(
                            'http://primary/Certs/<CATruncatedName>.cer'
                            'http://secondary/Certs/<CATruncatedName>.cer'
                        )
                        OcspUri             = @(
                            'http://primary-ocsp-responder/ocsp'
                            'http://secondary-ocsp-responder/ocsp'
                        )
                        AllowRestartService = $true
                    }
                )
            }
        }

        It 'Should compile and apply the MOF without throwing' {
            {
                & 'DSC_AdcsAuthorityInformationAccess_Config' `
                    -OutputPath $TestDrive `
                    -ConfigurationData $configData

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
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq 'DSC_AdcsAuthorityInformationAccess_Config'
            }
            $current.IsSingleInstance | Should -BeExactly 'Yes'
            $current.AiaList | Should -BeExactly $configData.AllNodes[0].AiaList
            $current.OcspList | Should -BeExactly $configData.AllNodes[0].OcspList
            $current.AllowRestartService | Should -BeFalse
        }
    }

    Context 'Clear ADCS Certification Authority Authority Information Access' {
        BeforeAll {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName            = 'localhost'
                        AiaUri              = @()
                        OcspUri             = @()
                        AllowRestartService = $true
                    }
                )
            }
        }

        It 'Should compile and apply the MOF without throwing' {
            {
                & 'DSC_AdcsAuthorityInformationAccess_Config' `
                    -OutputPath $TestDrive `
                    -ConfigurationData $configData

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
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq 'DSC_AdcsAuthorityInformationAccess_Config'
            }
            $current.IsSingleInstance | Should -BeExactly 'Yes'
            $current.AiaList | Should -BeNullOrEmpty
            $current.OcspList | Should -BeNullOrEmpty
            $current.AllowRestartService | Should -BeFalse
        }
    }
}

Describe "$($script:dscResourceName)_Uninstall_Integration" -Skip:$skipIntegrationTests {
    Context 'Uninstall ADCS Certification Authority' {
        BeforeAll {
            $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName)_Uninstall.config.ps1"
            . $configFile -Verbose -ErrorAction Stop

            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                    = 'localhost'
                        AdminCred                   = $script:adminCredential
                        PsDscAllowPlainTextPassword = $true
                    }
                )
            }
        }

        It 'Should compile and apply the MOF without throwing' {
            {
                & "$($script:dscResourceName)_Uninstall_Config" `
                    -OutputPath $TestDrive `
                    -ConfigurationData $configData `
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
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq "$($script:dscResourceName)_Uninstall_Config"
            }
            $current.Ensure | Should -Be 'Absent'
        }
    }
}
