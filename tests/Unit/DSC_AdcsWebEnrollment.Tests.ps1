$script:dscModuleName = 'ActiveDirectoryCSDsc'
$script:dscResourceName = 'DSC_AdcsWebEnrollment'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\AdcsStub.psm1')
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
    Remove-Module -Name AdcsStub -Force
}

Invoke-TestSetup

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
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

        Describe 'DSC_AdcsWebEnrollment\Get-TargetResource' {
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

        Describe 'DSC_AdcsWebEnrollment\Set-TargetResource' {
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
                    -MockWith { [PSObject] @{ ErrorString = 'Something went wrong' } }

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

        Describe 'DSC_AdcsWebEnrollment\Test-TargetResource' {
            Context 'When the Web Enrollment is installed' {
                Context 'When the Web Enrollment should be installed' {
                    Mock `
                        -CommandName Install-AdcsWebEnrollment `
                        -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentSetupException') } `
                        -Verifiable

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return true' {
                        $result | Should -BeTrue
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
                        $result | Should -BeFalse
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
                        $result | Should -BeFalse
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
                        $result | Should -BeTrue
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
    Invoke-TestCleanup
}
