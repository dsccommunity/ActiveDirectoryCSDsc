$script:DSCModuleName   = 'xAdcsDeployment'
$script:DSCResourceName = 'MSFT_xAdcsOnlineResponder'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Integration Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {
        $DSCResourceName = 'MSFT_xAdcsOnlineResponder'

        if (-not ([System.Management.Automation.PSTypeName]'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException').Type)
        {
            # Define the exception class:
            # Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException
            # so that unit tests can be run without ADCS being installed.

            $ExceptionDefinition = @'
namespace Microsoft.CertificateServices.Deployment.Common.OCSP {
    public class OnlineResponderSetupException: System.Exception {
    }
}
'@
            Add-Type -TypeDefinition $ExceptionDefinition
        }

        $DummyCredential = New-Object System.Management.Automation.PSCredential ("Administrator",(New-Object -Type SecureString))

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

        function Install-AdcsOnlineResponder {
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

        function Uninstall-AdcsOnlineResponder {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [Switch]
                $Force
            )
        }

        Describe "$DSCResourceName\Get-TargetResource" {
            Context 'Online Responder is installed' {
                Mock `
                    -CommandName Install-AdcsOnlineResponder `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                    -Verifiable

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Present' {
                    $result.Ensure  | Should -Be 'Present'
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMocks
                    Assert-MockCalled `
                        -CommandName Install-AdcsOnlineResponder `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'Online Responder is not installed' {
                Mock -CommandName Install-AdcsOnlineResponder

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Absent' {
                    $result.Ensure  | Should -Be 'Absent'
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsOnlineResponder `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe "$DSCResourceName\Set-TargetResource" {
            Context 'Online Responder is not installed but should be' {
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

            Context 'Online Responder is not installed but should be but an error is thrown installing it' {
                Mock -CommandName Install-AdcsOnlineResponder `
                    -MockWith { [PSObject] @{ ErrorString = 'Something went wrong' }}

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

            Context 'Online Responder is installed but should not be' {
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

        Describe "$DSCResourceName\Test-TargetResource" {
            Context 'Online Responder is installed' {
                Context 'Online Responder should be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                        -Verifiable

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return true' {
                        $result | Should -Be $True
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMocks
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'Online Responder should not be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                        -Verifiable

                    $result = Test-TargetResource @TestParametersAbsent

                    It 'Should return false' {
                        $result | Should -Be $False
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMocks
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
                            -Exactly `
                            -Times 1
                    }
                }
            }

            Context 'Online Responder is not installed' {
                Context 'Online Responder should be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -Verifiable

                    $result = Test-TargetResource @testParametersPresent

                    It 'Should return false' {
                        $result | Should -Be $false
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMocks
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'Online Responder should not be installed' {
                    Mock -CommandName Install-AdcsOnlineResponder `
                        -Verifiable

                    $result = Test-TargetResource @TestParametersAbsent

                    It 'Should return true' {
                        $result | Should -Be $True
                    }

                    It 'Should call expected mocks' {
                        Assert-VerifiableMocks
                        Assert-MockCalled `
                            -CommandName Install-AdcsOnlineResponder `
                            -Exactly `
                            -Times 1
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
