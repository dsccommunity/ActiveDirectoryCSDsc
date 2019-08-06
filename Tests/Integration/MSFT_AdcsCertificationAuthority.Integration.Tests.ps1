<#
    Suppress this PSSA message because we need to allow credentials to be
    set when running the tests.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

<#
    This integration test validates both AdcsCertificationAuthority
    and AdcsCertificationAuthoritySettings.
#>
$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsCertificationAuthority'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Integration Test Template Version: 1.1.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    <#
        IMPORTANT: To run these tests requires a local Administrator account to be
        available on the machine running the tests that can be used to install the
        ADCS component being tested. This account will be created automatically for
        the tests and removed afterward.

        When these tests are run on AppVeyor, ADCS-Cert-Authority will be installed
        and a new Administrator account will be created that uses credentials that
        match the ones following.
    #>
    $script:adminUsername = 'AdcsAdminTest'
    $script:adminPassword = ConvertTo-SecureString -String 'NotPass12!' -AsPlainText -Force

    # Ensure that the tests can be performed on this computer
    if (-not (Test-WindowsFeature -Name 'ADCS-Cert-Authority'))
    {
        Write-Warning -Message 'Skipping integration tests for AdcsCertificationAuthority because the feature ADCS-Cert-Authority is not installed.'
        return
    }

    # Create a new Local User in the administrators group
    $script:adminCredential = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList ($script:adminUsername, $script:adminPassword)
    New-LocalUserInAdministratorsGroup -Username $script:adminUsername -Password $script:adminPassword

    Describe "$($script:DSCResourceName)_Install_Integration" {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_Install.config.ps1"
        . $configFile -Verbose -ErrorAction Stop

        Context 'Install ADCS Certification Authority' {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                    = 'localhost'
                        AdminCred                   = $script:adminCredential
                        PsDscAllowPlainTextPassword = $true
                    }
                )
            }

            It 'Should compile and apply the MOF without throwing' {
                {
                    & "$($script:DSCResourceName)_Install_Config" `
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
                    $_.ConfigurationName -eq "$($script:DSCResourceName)_Install_Config"
                }
                $current.Ensure | Should -Be 'Present'
            }
        }
    }

    Describe 'MSFT_AdcsCertificationAuthoritySettings_Integration' {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_AdcsCertificationAuthoritySettings.config.ps1'
        . $configFile -Verbose -ErrorAction Stop

        Context 'Install ADCS Certification Authority' {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                    = 'localhost'
                        PsDscAllowPlainTextPassword = $true
                        CACertPublicationURLs = @(
                            '1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt'
                            '2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11'
                            '2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt'
                        )
                        CRLPublicationURLs =  @(
                            '65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl'
                            '79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10'
                            '6:http://pki.contoso.com/CertEnroll/%3%8%9.crl'
                        )
                        CRLOverlapUnits = 8
                        CRLOverlapPeriod = 'Hours'
                        CRLPeriodUnits = 1
                        CRLPeriod = 'Months'
                        ValidityPeriodUnits = 10
                        ValidityPeriod = 'Years'
                        DSConfigDN = 'CN=Configuration,DC=CONTOSO,DC=COM'
                        DSDomainDN = 'DC=CONTOSO,DC=COM'
                        AuditFilter = @(
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

            It 'Should compile and apply the MOF without throwing' {
                {
                    & "MSFT_AdcsCertificationAuthoritySettings_Config" `
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
                    $_.ConfigurationName -eq 'MSFT_AdcsCertificationAuthoritySettings_Config'
                }
                $current.CACertPublicationURLs | Should -BeExactly $configData.AllNodes[0].CACertPublicationURLs
                $current.CRLPublicationURLs    | Should -BeExactly $configData.AllNodes[0].CRLPublicationURLs
                $current.CRLOverlapUnits       | Should -BeExactly $configData.AllNodes[0].CRLOverlapUnits
                $current.CRLOverlapPeriod      | Should -BeExactly $configData.AllNodes[0].CRLOverlapPeriod
                $current.CRLPeriodUnits        | Should -BeExactly $configData.AllNodes[0].CRLPeriodUnits
                $current.CRLPeriod             | Should -BeExactly $configData.AllNodes[0].CRLPeriod
                $current.ValidityPeriodUnits   | Should -BeExactly $configData.AllNodes[0].ValidityPeriodUnits
                $current.ValidityPeriod        | Should -BeExactly $configData.AllNodes[0].ValidityPeriod
                $current.DSConfigDN            | Should -BeExactly $configData.AllNodes[0].DSConfigDN
                $current.DSDomainDN            | Should -BeExactly $configData.AllNodes[0].DSDomainDN
                $current.AuditFilter           | Should -BeExactly $configData.AllNodes[0].AuditFilter
            }
        }
    }

    Describe "$($script:DSCResourceName)_Uninstall_Integration" {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_Uninstall.config.ps1"
        . $configFile -Verbose -ErrorAction Stop

        Context 'Uninstall ADCS Certification Authority' {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                    = 'localhost'
                        AdminCred                   = $script:adminCredential
                        PsDscAllowPlainTextPassword = $true
                    }
                )
            }

            It 'Should compile and apply the MOF without throwing' {
                {
                    & "$($script:DSCResourceName)_Uninstall_Config" `
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
                    $_.ConfigurationName -eq "$($script:DSCResourceName)_Uninstall_Config"
                }
                $current.Ensure | Should -Be 'Absent'
            }
        }
    }
}
finally
{
    #region FOOTER
    Remove-LocalUser -Name $script:adminUsername -ErrorAction SilentlyContinue
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
