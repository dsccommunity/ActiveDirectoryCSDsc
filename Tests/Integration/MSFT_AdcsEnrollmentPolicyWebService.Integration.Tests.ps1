<#
    Suppress this PSSA message because we need to allow credentials to be
    set when running the tests.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsEnrollmentPolicyWebService'
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
    $certificate = New-SelfSignedCertificate `
        -DnsName $ENV:ComputerName `
        -CertStoreLocation Cert:\LocalMachine\My

    Describe "$($script:DSCResourceName) integration test" {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
        . $configFile -Verbose -ErrorAction Stop

        # These are the test cases to run integration tests for
        $testAdcsEnrollmentPolicyWebServiceTestCases = @(
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

        foreach ($testAdcsEnrollmentPolicyWebServiceTestCase in $testAdcsEnrollmentPolicyWebServiceTestCases)
        {
            $authenticationType = $testAdcsEnrollmentPolicyWebServiceTestCase.AuthenticationType
            $keyBasedRenewal = $testAdcsEnrollmentPolicyWebServiceTestCase.KeyBasedRenewal

            Context "Install ADCS Enrollment Policy Web Service for AuthenticationType '$authenticationType' and KeyBasedRenewal '$keyBasedRenewal'" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        $ConfigData = @{
                            AllNodes = @(
                                @{
                                    NodeName                    = 'localhost'
                                    AuthenticationType          = $authenticationType
                                    SslCertThumbprint           = $certificate.Thumbprint
                                    Credential                  = $script:adminCredential
                                    KeyBasedRenewal             = $keyBasedRenewal
                                    Ensure                      = 'Present'
                                    PsDscAllowPlainTextPassword = $true
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
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
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.Ensure | Should -Be 'Present'
                }
            }

            Context "Uninstall ADCS Enrollment Policy Web Service for AuthenticationType '$authenticationType' and KeyBasedRenewal '$keyBasedRenewal'" {
                It 'Should compile and apply the MOF without throwing' {
                    {
                        $ConfigData = @{
                            AllNodes = @(
                                @{
                                    NodeName                    = 'localhost'
                                    AuthenticationType          = $authenticationType
                                    SslCertThumbprint           = $certificate.Thumbprint
                                    Credential                  = $script:adminCredential
                                    KeyBasedRenewal             = $keyBasedRenewal
                                    Ensure                      = 'Absent'
                                    PsDscAllowPlainTextPassword = $true
                                }
                            )
                        }

                        & "$($script:DSCResourceName)_Config" `
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
                        $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
                    }
                    $current.Ensure | Should -Be 'Absent'
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    # Remove the SSL certificate created for the Web Service
    if ($certificate)
    {
        $null = Remove-Item `
            -Path $certificate.PSPath `
            -Force
    }

    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
