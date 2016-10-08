# Suppress this PSSA message because we need to allow credentials to be
# set when running the tests.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

# IMPORTANT: To run these tests requires a local Administrator account to be
# available on the machine running the tests that can be used to install the
# ADCS component being tested. Please change the following values to the
# credentials that are set up for this purpose.
# These tests can not be run on AppVeyor because installing ADCS components
# on WS2012R2 requires restart of the server which is not supported.
# However, on WS2016 ADCS installation does not require a restart so when
# this machine type is available executing these tests should be supported.
$script:adminUsername   = 'AdcsAdmin'
$script:adminPassword   = 'NotARealPassword!'
$script:DSCModuleName   = 'xAdcsDeployment'
$script:DSCResourceName = 'MSFT_xAdcsCertificationAuthority'

#region HEADER
# Integration Test Template Version: 1.1.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    # Import the common integration test functions
    Import-Module -Name ( Join-Path `
        -Path $PSScriptRoot `
        -ChildPath 'IntegrationTestsCommon.psm1' )

    # Ensure that the tests can be performed on this computer
    if (-not (Test-WindowsFeature -Name 'ADCS-Cert-Authority'))
    {
        Return
    }

    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_Install.config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Install_Integration" {
        Context 'Install ADCS Certification Authority' {
            #region DEFAULT TESTS
            It 'Should compile without throwing' {
                {
                    $secureAdminPassword = ConvertTo-SecureString -String $script:adminPassword -AsPlainText -Force
                    $adminCred = New-Object -TypeName System.Management.Automation.PSCredential `
                        -ArgumentList ($script:adminUsername,$secureAdminPassword)
                    $ConfigData = @{
                        AllNodes = @(
                            @{
                                NodeName                    = 'localhost'
                                AdminCred                   = $AdminCred
                                PsDscAllowPlainTextPassword = $true
                            }
                        )
                    }

                    & "$($script:DSCResourceName)_Install_Config" `
                        -OutputPath $TestEnvironment.WorkingFolder `
                        -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }
            #endregion

            It 'Should have set the resource and all the parameters should match' {
                $current = Get-DscConfiguration | Where-Object {
                    $_.ConfigurationName -eq "$($script:DSCResourceName)_Install_Config"
                }
                $current.Ensure           | Should Be 'Present'
            }
        }
    }

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_Uninstall.config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Uninstall_Integration" {
        Context 'Uninstall ADCS Certification Authority' {
            #region DEFAULT TESTS
            It 'Should compile without throwing' {
                {
                    $secureAdminPassword = ConvertTo-SecureString -String $script:adminPassword -AsPlainText -Force
                    $adminCred = New-Object -TypeName System.Management.Automation.PSCredential `
                        -ArgumentList ($script:adminUsername,$secureAdminPassword)
                    $ConfigData = @{
                        AllNodes = @(
                            @{
                                NodeName                    = 'localhost'
                                AdminCred                   = $AdminCred
                                PsDscAllowPlainTextPassword = $true
                            }
                        )
                    }

                    & "$($script:DSCResourceName)_Uninstall_Config" `
                        -OutputPath $TestEnvironment.WorkingFolder `
                        -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }
            #endregion

            It 'Should have set the resource and all the parameters should match' {
                $current = Get-DscConfiguration | Where-Object {
                    $_.ConfigurationName -eq "$($script:DSCResourceName)_Uninstall_Config"
                }
                $current.Ensure           | Should Be 'Absent'
            }
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
