<#
    Suppress this PSSA message because we need to allow credentials to be
    set when running the tests.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

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
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configData = @{
                        AllNodes = @(
                            @{
                                NodeName                    = 'localhost'
                                AdminCred                   = $script:adminCredential
                                PsDscAllowPlainTextPassword = $true
                            }
                        )
                    }

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
                $current = Get-DscConfiguration | Where-Object {
                    $_.ConfigurationName -eq "$($script:DSCResourceName)_Install_Config"
                }
                $current.Ensure | Should -Be 'Present'
            }
        }
    }

    Describe "$($script:DSCResourceName)_Uninstall_Integration" {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_Uninstall.config.ps1"
        . $configFile -Verbose -ErrorAction Stop

        Context 'Uninstall ADCS Certification Authority' {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configData = @{
                        AllNodes = @(
                            @{
                                NodeName                    = 'localhost'
                                AdminCred                   = $script:adminCredential
                                PsDscAllowPlainTextPassword = $true
                            }
                        )
                    }

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
                $current = Get-DscConfiguration | Where-Object {
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
