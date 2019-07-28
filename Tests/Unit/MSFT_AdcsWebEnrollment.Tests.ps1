$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsWebEnrollment'

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
        if (-not ([System.Management.Automation.PSTypeName]'Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentSetupException').Type)
        {
            <#
                Define the exception class:
                Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentSetupException
                so that unit tests can be run without ADCS being installed.
            #>

            $ExceptionDefinition = @'
namespace Microsoft.CertificateServices.Deployment.Common.WEP {
    public class WebEnrollmentSetupException: System.Exception {
    }
}
'@
            Add-Type -TypeDefinition $ExceptionDefinition
        }

        $dummyCredential = New-Object System.Management.Automation.PSCredential ("Administrator", (New-Object -Type SecureString))

        $testParametersPresent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            CAConfig         = 'CAConfig'
            Credential       = $dummyCredential
            Verbose          = $true
        }

        $testParametersAbsent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Absent'
            Credential       = $dummyCredential
            Verbose          = $true
        }

        function Install-AdcsWebEnrollment
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [String]
                $CAConfig,

                [Parameter()]
                [System.Management.Automation.PSCredential]
                $Credential,

                [Parameter()]
                [Switch]
                $Force,

                [Parameter()]
                [Switch]
                $WhatIf
            )
        }

        function Uninstall-AdcsWebEnrollment
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [Switch]
                $Force
            )
        }

        Describe 'MSFT_AdcsWebEnrollment\Get-TargetResource' {
            Context 'When the Web Enrollment is installed' {
                Mock `
                    -CommandName Install-AdcsWebEnrollment `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentSetupException') } `
                    -Verifiable

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Present' {
                    $result.Ensure | Should -Be 'Present'
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock

                    Assert-MockCalled `
                        -CommandName Install-AdcsWebEnrollment `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the Web Enrollment is not installed' {
                Mock `
                    -CommandName Install-AdcsWebEnrollment

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Absent' {
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsWebEnrollment `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'MSFT_AdcsWebEnrollment\Set-TargetResource' {
            Context 'When the Web Enrollment is not installed but should be' {
                Mock -CommandName Install-AdcsWebEnrollment
                Mock -CommandName Uninstall-AdcsWebEnrollment

                It 'Should not throw an exception' {
                    { Set-TargetResource @testParametersPresent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsWebEnrollment `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsWebEnrollment `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the Web Enrollment is not installed but should be but an error is thrown installing it' {
                Mock -CommandName Install-AdcsWebEnrollment `
                    -MockWith { [PSObject] @{ ErrorString = 'Something went wrong' }}

                Mock -CommandName Uninstall-AdcsWebEnrollment

                It 'Should not throw an exception' {
                    $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                    { Set-TargetResource @testParametersPresent } | Should Throw $errorRecord
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsWebEnrollment `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsWebEnrollment `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the Web Enrollment is installed but should not be' {
                Mock -CommandName Install-AdcsWebEnrollment
                Mock -CommandName Uninstall-AdcsWebEnrollment

                It 'Should not throw an exception' {
                    { Set-TargetResource @TestParametersAbsent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsWebEnrollment `
                        -Exactly `
                        -Times 0

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsWebEnrollment `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'MSFT_AdcsWebEnrollment\Test-TargetResource' {
            Context 'When the Web Enrollment is installed' {
                Context 'When the Web Enrollment should be installed' {
                    Mock `
                        -CommandName Install-AdcsWebEnrollment `
                        -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentSetupException') } `
                        -Verifiable

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return true' {
                        $result | Should -Be $True
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock

                        Assert-MockCalled `
                            -CommandName Install-AdcsWebEnrollment `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'When the Web Enrollment should not be installed' {
                    Mock `
                        -CommandName Install-AdcsWebEnrollment `
                        -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentSetupException') } `
                        -Verifiable

                    $result = Test-TargetResource @testParametersAbsent

                    It 'Should return false' {
                        $result | Should -Be $False
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock

                        Assert-MockCalled `
                            -CommandName Install-AdcsWebEnrollment `
                            -Exactly `
                            -Times 1
                    }
                }
            }

            Context 'When the Web Enrollment is not installed' {
                Context 'When the Web Enrollment should be installed' {
                    Mock -CommandName Install-AdcsWebEnrollment -Verifiable

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return false' {
                        $result | Should -Be $false
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock

                        Assert-MockCalled `
                            -CommandName Install-AdcsWebEnrollment `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'When the Web Enrollment should not be installed' {
                    Mock -CommandName Install-AdcsWebEnrollment -Verifiable

                    $result = Test-TargetResource @testParametersAbsent

                    It 'Should return true' {
                        $result | Should -Be $True
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock

                        Assert-MockCalled `
                            -CommandName Install-AdcsWebEnrollment `
                            -Exactly `
                            -Times 1
                    }
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
