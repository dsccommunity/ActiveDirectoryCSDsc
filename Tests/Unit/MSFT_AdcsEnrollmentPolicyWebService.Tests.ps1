$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsEnrollmentPolicyWebService'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

try
{
    InModuleScope $script:DSCResourceName {
        if (-not ([System.Management.Automation.PSTypeName]'Microsoft.CertificateServices.Deployment.Commands.CEP.EnrollmentPolicyServiceSetupException').Type)
        {
            # Define the exception class:
            # Microsoft.CertificateServices.Deployment.Commands.CEP.EnrollmentPolicyServiceSetupException
            # so that unit tests can be run without ADCS being installed.

            $ExceptionDefinition = @'
namespace Microsoft.CertificateServices.Deployment.Commands.CEP {
    public class EnrollmentPolicyServiceSetupException: System.Exception {
    }
}
'@
            Add-Type -TypeDefinition $ExceptionDefinition
        }

        $dummyCredential = New-Object `
            -TypeName System.Management.Automation.PSCredential `
            -ArgumentList ('Administrator', (New-Object -TypeName SecureString))

        $testParametersPresent = @{
            AuthenticationType = 'Certificate'
            SslCertThumbprint  = 'B2E43FF3E02D1EE767C06BD905F292E33BD14C1A'
            Credential         = $dummyCredential
            KeyBasedRenewal    = $true
            Ensure             = 'Present'
            Verbose            = $true
        }

        $testParametersAbsent = $testParametersPresent.Clone()
        $testParametersAbsent.Ensure = 'Absent'

        $testParametersGet = @{
            AuthenticationType = 'Certificate'
            SslCertThumbprint  = 'B2E43FF3E02D1EE767C06BD905F292E33BD14C1A'
            Credential         = $dummyCredential
            KeyBasedRenewal    = $true
            Verbose            = $true
        }

        $invalidThumbprint = 'Zebra'

        # This thumbprint is valid (but not FIPS valid)
        $validThumbprint = (
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | Where-Object {
                $_.BaseType.BaseType -eq [System.Security.Cryptography.HashAlgorithm] -and
                ($_.Name -cmatch 'Managed$' -or $_.Name -cmatch 'Provider$')
            } | Select-Object -First 1 | ForEach-Object {
                (New-Object $_).ComputeHash([String]::Empty) | ForEach-Object {
                    '{0:x2}' -f $_
                }
            }
        ) -join ''

        # This thumbprint is valid for FIPS
        $validFipsThumbprint = (
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | Where-Object {
                $_.BaseType.BaseType -eq [System.Security.Cryptography.HashAlgorithm] -and
                ($_.Name -cmatch 'Provider$' -and $_.Name -cnotmatch 'MD5')
            } | Select-Object -First 1 | ForEach-Object {
                (New-Object $_).ComputeHash([String]::Empty) | ForEach-Object {
                    '{0:x2}' -f $_
                }
            }
        ) -join ''

        function Install-AdcsEnrollmentPolicyWebService
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [ValidateSet('Certificate', 'Kerberos', 'UserName')]
                [System.String]
                $AuthenticationType,

                [Parameter()]
                [System.String]
                $SslCertThumbprint,

                [Parameter()]
                [System.Management.Automation.PSCredential]
                $Credential,

                [Parameter()]
                [System.Boolean]
                $KeyBasedRenewal = $false,

                [Parameter()]
                [Switch]
                $Force,

                [Parameter()]
                [Switch]
                $WhatIf
            )
        }

        function Uninstall-AdcsEnrollmentPolicyWebService
        {
            [CmdletBinding()]
            param
            (
                [ValidateSet('Certificate', 'Kerberos', 'UserName')]
                [String]
                $AuthenticationType,

                [Parameter()]
                [System.Boolean]
                $KeyBasedRenewal,

                [Parameter()]
                [Switch]
                $Force
            )
        }

        Describe 'MSFT_AdcsEnrollmentPolicyWebService\Get-TargetResource' {
            Context 'When the Enrollment Policy Web Service is installed' {
                Mock `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -MockWith { $true }

                $result = Get-TargetResource @testParametersGet

                It 'Should return Ensure set to Present' {
                    $result.Ensure | Should -Be 'Present'
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock

                    Assert-MockCalled `
                        -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the Enrollment Policy Web Service is not installed' {
                Mock `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -MockWith { $false }

                $result = Get-TargetResource @testParametersGet

                It 'Should return Ensure set to Absent' {
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'MSFT_AdcsEnrollmentPolicyWebService\Set-TargetResource' {
            Context 'When the Enrollment Policy Web Service is not installed but should be' {
                Mock -CommandName Install-AdcsEnrollmentPolicyWebService
                Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService

                It 'Should not throw an exception' {
                    { Set-TargetResource @testParametersPresent } | Should -Not -Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the Enrollment Policy Web Service is not installed but should be but an error string is returned installing it' {
                Mock -CommandName Install-AdcsEnrollmentPolicyWebService `
                    -MockWith {
                    [PSObject] @{ ErrorString = 'Something went wrong' }
                }

                Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService

                It 'Should not throw an exception' {
                    $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                    { Set-TargetResource @testParametersPresent } | Should -Throw $errorRecord
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the Enrollment Policy Web Service is not installed but should be but an exception is thrown installing it' {
                Mock -CommandName Install-AdcsEnrollmentPolicyWebService `
                    -MockWith { throw 'Something went wrong' }

                Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService

                It 'Should not throw an exception' {
                    $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                    { Set-TargetResource @testParametersPresent } | Should -Throw $errorRecord
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the Enrollment Policy Web Service is installed but should not be' {
                Mock -CommandName Install-AdcsEnrollmentPolicyWebService
                Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService

                It 'Should not throw an exception' {
                    { Set-TargetResource @testParametersAbsent } | Should -Not -Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 0

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'MSFT_AdcsEnrollmentPolicyWebService\Test-TargetResource' {
            Context 'When the Enrollment Policy Web Service is installed' {
                Context 'When the Enrollment Policy Web Service should be installed' {
                    Mock `
                        -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -MockWith { $true }

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return true' {
                        $result | Should -Be $True
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'When the Enrollment Policy Web Service should not be installed' {
                    Mock `
                        -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -MockWith { $true }

                    $result = Test-TargetResource @testParametersAbsent

                    It 'Should return false' {
                        $result | Should -Be $False
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                            -Exactly `
                            -Times 1
                    }
                }
            }

            Context 'When the Enrollment Policy Web Service is not installed' {
                Context 'When the Enrollment Policy Web Service should be installed' {
                    Mock `
                        -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -MockWith { $false }

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return false' {
                        $result | Should -Be $false
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'When the Enrollment Policy Web Service should not be installed' {
                    Mock `
                        -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -MockWith { $false }

                    $result = Test-TargetResource @testParametersAbsent

                    It 'Should return true' {
                        $result | Should -Be $True
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                            -Exactly `
                            -Times 1
                    }
                }
            }
        }

        Describe 'MSFT_AdcsEnrollmentPolicyWebService\Test-AdcsEnrollmentPolicyWebServiceInstallState' {
            $testAdcsEnrollmentPolicyWebServiceInstallStateTestCases = @(
                @{
                    AuthenticationType = 'Certificate'
                    KeyBasedRenewal    = $false
                    WebAppName         = 'ADPolicyProvider_CEP_Certificate'
                    Applicationpool    = 'WSEnrollmentPolicyServer'
                    PhysicalPath       = "C:\Windows\SystemData\CEP\ADPolicyProvider_CEP_Certificate"
                },
                @{
                    AuthenticationType = 'Certificate'
                    KeyBasedRenewal    = $true
                    WebAppName         = 'KeyBasedRenewal_ADPolicyProvider_CEP_Certificate'
                    Applicationpool    = 'WSEnrollmentPolicyServer'
                    PhysicalPath       = "C:\Windows\SystemData\CEP\KeyBasedRenewal_ADPolicyProvider_CEP_Certificate"
                },
                @{
                    AuthenticationType = 'Kerberos'
                    KeyBasedRenewal    = $false
                    WebAppName         = 'ADPolicyProvider_CEP_Kerberos'
                    Applicationpool    = 'WSEnrollmentPolicyServer'
                    PhysicalPath       = "C:\Windows\SystemData\CEP\ADPolicyProvider_CEP_Kerberos"
                },
                @{
                    AuthenticationType = 'UserName'
                    KeyBasedRenewal    = $false
                    WebAppName         = 'ADPolicyProvider_CEP_UsernamePassword'
                    Applicationpool    = 'WSEnrollmentPolicyServer'
                    PhysicalPath       = "C:\Windows\SystemData\CEP\ADPolicyProvider_CEP_UsernamePassword"
                },
                @{
                    AuthenticationType = 'UserName'
                    KeyBasedRenewal    = $true
                    WebAppName         = 'KeyBasedRenewal_ADPolicyProvider_CEP_UsernamePassword'
                    Applicationpool    = 'WSEnrollmentPolicyServer'
                    PhysicalPath       = "C:\Windows\SystemData\CEP\KeyBasedRenewal_ADPolicyProvider_CEP_UsernamePassword"
                }
            )
            $mockAdcsEnrollmentPolicyWebServiceInstallStateAllInstalled = {
                $testAdcsEnrollmentPolicyWebServiceInstallStateTestCases
            }
            $mockAdcsEnrollmentPolicyWebServiceInstallStateNoneInstalled = {
                @()
            }

            Context 'When matching Enrollment Policy Web Service is installed' {
                BeforeEach {
                    Mock `
                        -CommandName Get-WebApplication `
                        -MockWith $mockAdcsEnrollmentPolicyWebServiceInstallStateAllInstalled
                }

                It 'Given AuthenticationType <AuthenticationType> and KeyBasedRenewal <KeyBasedRenewal> it should return $true' -TestCases $testAdcsEnrollmentPolicyWebServiceInstallStateTestCases {
                    param (
                        [Parameter()]
                        $AuthenticationType,

                        [Parameter()]
                        $KeyBasedRenewal,

                        [Parameter()]
                        $WebAppName,

                        [Parameter()]
                        $Applicationpool,

                        [Parameter()]
                        $PhysicalPath
                    )
                    $result = Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -AuthenticationType $AuthenticationType `
                        -KeyBasedRenewal:$KeyBasedRenewal `
                        -Verbose

                    $result | Should -Be $true
                }
            }

            Context 'When matching Enrollment Policy Web Service is not installed' {
                BeforeEach {
                    Mock `
                        -CommandName Get-WebApplication `
                        -MockWith $mockAdcsEnrollmentPolicyWebServiceInstallStateNoneInstalled
                }

                It 'Given AuthenticationType <AuthenticationType> and KeyBasedRenewal <KeyBasedRenewal> it should return $false' -TestCases $testAdcsEnrollmentPolicyWebServiceInstallStateTestCases {
                    param (
                        [Parameter()]
                        $AuthenticationType,

                        [Parameter()]
                        $KeyBasedRenewal,

                        [Parameter()]
                        $WebAppName,

                        [Parameter()]
                        $Applicationpool,

                        [Parameter()]
                        $PhysicalPath
                    )
                    $result = Test-AdcsEnrollmentPolicyWebServiceInstallState `
                        -AuthenticationType $AuthenticationType `
                        -KeyBasedRenewal:$KeyBasedRenewal `
                        -Verbose

                    $result | Should -Be $false
                }
            }
        }

        Describe 'MSFT_AdcsEnrollmentPolicyWebService\Test-Thumbprint' {
            Context 'When FIPS not set' {
                Context 'When a single valid thumbrpint by parameter is passed' {
                    $result = Test-Thumbprint -Thumbprint $validThumbprint
                    It 'Should return true' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $true
                    }
                }

                Context 'When a single invalid thumbprint by parameter is passed' {
                    It 'Should throw an exception' {
                        { Test-Thumbprint -Thumbprint $invalidThumbprint } | Should -Throw
                    }
                }

                Context 'When a single invalid thumbprint by parameter with -Quiet is passed' {
                    $result = Test-Thumbprint $invalidThumbprint -Quiet
                    It 'Should return false' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $false
                    }
                }

                Context 'When a single valid thumbprint by pipeline is passed' {
                    $result = $validThumbprint | Test-Thumbprint
                    It 'Should return true' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $true
                    }
                }

                Context 'When a single invalid thumbprint by pipeline is passed' {
                    It 'Should throw an exception' {
                        { $invalidThumbprint | Test-Thumbprint } | Should -Throw
                    }
                }

                Context 'When a single invalid thumbprint by pipeline with -Quiet is passed' {
                    $result = $invalidThumbprint | Test-Thumbprint -Quiet
                    It 'Should return false' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $false
                    }
                }
            }

            Context 'When FIPS is enabled' {
                Mock -CommandName Get-ItemProperty -MockWith { @{ Enabled = 1 } }

                Context 'When a single valid FIPS thumbrpint by parameter is passed' {
                    $result = Test-Thumbprint -Thumbprint $validFipsThumbprint
                    It 'Should return true' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $true
                    }
                }

                Context 'When a single invalid FIPS thumbprint by parameter is passed' {
                    It 'Should throw an exception' {
                        { Test-Thumbprint -Thumbprint $validThumbprint } | Should -Throw
                    }
                }

                Context 'When a single invalid FIPS thumbprint by parameter with -Quiet is passed' {
                    $result = Test-Thumbprint $validThumbprint -Quiet
                    It 'Should return false' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $false
                    }
                }

                Context 'When a single valid FIPS thumbprint by pipeline is passed' {
                    $result = $validFipsThumbprint | Test-Thumbprint
                    It 'Should return true' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $true
                    }
                }

                Context 'When a single invalid FIPS thumbprint by pipeline is passed' {
                    It 'Should throw an exception' {
                        { $validThumbprint | Test-Thumbprint } | Should -Throw
                    }
                }

                Context 'When a single invalid FIPS thumbprint by pipeline with -Quiet is passed' {
                    $result = $validThumbprint | Test-Thumbprint -Quiet
                    It 'Should return false' {
                        $result | Should -BeOfType [System.Boolean]
                        $result | Should -Be $false
                    }
                }
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
