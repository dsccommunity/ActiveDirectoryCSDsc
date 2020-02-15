$script:dscModuleName = 'ActiveDirectoryCSDsc'
$script:dscResourceName = 'DSC_AdcsOnlineResponder'

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
}

Invoke-TestSetup

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
        if (-not ([System.Management.Automation.PSTypeName]'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException').Type)
        {
            <#
                Define the exception class:
                Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException
                so that unit tests can be run without ADCS being installed.
            #>

            $ExceptionDefinition = @'
namespace Microsoft.CertificateServices.Deployment.Common.OCSP {
    public class OnlineResponderSetupException: System.Exception {
    }
}
'@
            Add-Type -TypeDefinition $ExceptionDefinition
        }

        $DummyCredential = New-Object System.Management.Automation.PSCredential ("Administrator", (New-Object -Type SecureString))

        $testParametersPresent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            Credential       = $DummyCredential
            Verbose          = $true
        }

        $TestParametersAbsent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Absent'
            Credential       = $DummyCredential
            Verbose          = $true
        }

        function Install-AdcsOnlineResponder
        {
            [CmdletBinding()]
            param
            (
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

        function Uninstall-AdcsOnlineResponder
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [Switch]
                $Force
            )
        }

        Describe 'DSC_AdcsOnlineResponder\Get-TargetResource' {
            Context 'When the Online Responder is installed' {
                Mock `
                    -CommandName Install-AdcsOnlineResponder `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                    -Verifiable

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Present' {
                    $result.Ensure | Should -Be 'Present'
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock
                    Assert-MockCalled `
                        -CommandName Install-AdcsOnlineResponder `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the Online Responder is not installed' {
                Mock -CommandName Install-AdcsOnlineResponder

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Absent' {
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsOnlineResponder `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'DSC_AdcsOnlineResponder\Set-TargetResource' {
            Context 'When the Online Responder is not installed but should be' {
                Mock -CommandName Install-AdcsOnlineResponder
                Mock -CommandName Uninstall-AdcsOnlineResponder

                It 'Should not throw an exception' {
                    { Set-TargetResource @testParametersPresent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsOnlineResponder `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsOnlineResponder `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the Online Responder is not installed but should be but an error is thrown installing it' {
                Mock -CommandName Install-AdcsOnlineResponder `
                    -MockWith { [PSObject] @{ ErrorString = 'Something went wrong' } }

                Mock -CommandName Uninstall-AdcsOnlineResponder

                It 'Should throw an exception' {
                    $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                    { Set-TargetResource @testParametersPresent } | Should Throw $errorRecord
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsOnlineResponder `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsOnlineResponder `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the Online Responder is installed but should not be' {
                Mock -CommandName Install-AdcsOnlineResponder
                Mock -CommandName Uninstall-AdcsOnlineResponder

                It 'Should not throw an exception' {
                    { Set-TargetResource @TestParametersAbsent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsOnlineResponder `
                        -Exactly `
                        -Times 0

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsOnlineResponder `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'DSC_AdcsOnlineResponder\Test-TargetResource' {
            Context 'When the Online Responder is installed' {
                Context 'When the Online Responder should be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                        -Verifiable

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return true' {
                        $result | Should -BeTrue
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'When the Online Responder should not be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                        -Verifiable

                    $result = Test-TargetResource @TestParametersAbsent

                    It 'Should return false' {
                        $result | Should -BeFalse
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
                            -Exactly `
                            -Times 1
                    }
                }
            }

            Context 'When the Online Responder is not installed' {
                Context 'When the Online Responder should be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -Verifiable

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return false' {
                        $result | Should -BeFalse
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'When the Online Responder should not be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -Verifiable

                    $result = Test-TargetResource @TestParametersAbsent

                    It 'Should return true' {
                        $result | Should -BeTrue
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMock
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
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
    Remove-Module -Name AdcsStub -Force
}
