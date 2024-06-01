<#
    .SYNOPSIS
        Unit test for DSC_AdcsOnlineResponder DSC resource.

    .NOTES
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
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
}

BeforeAll {
    $script:dscModuleName = 'ActiveDirectoryCSDsc'
    $script:dscResourceName = 'DSC_AdcsOnlineResponder'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\Stubs\AdcsDeploymentStub.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName

    # Add Custom Type
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

    # Add Test Data
    InModuleScope -ScriptBlock {
        $DummyCredential = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))

        $script:testParametersPresent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            Credential       = $DummyCredential
            Verbose          = $false
        }

        $script:TestParametersAbsent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Absent'
            Credential       = $DummyCredential
            Verbose          = $false
        }
    }
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    Remove-Module -Name AdcsDeploymentStub -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe 'DSC_AdcsOnlineResponder\Get-TargetResource' -Tag 'Get' {
    Context 'When the Online Responder is installed' {
        BeforeAll {
            Mock `
                -CommandName Install-AdcsOnlineResponder `
                -MockWith {
                Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException')
            } -Verifiable
        }


        It 'Should return Ensure set to Present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult = Get-TargetResource @testParametersPresent
                $getTargetResourceResult.Ensure | Should -Be 'Present'
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsOnlineResponder `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When the Online Responder is not installed' {
        BeforeAll {
            Mock -CommandName Install-AdcsOnlineResponder
        }


        It 'Should return Ensure set to Absent' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult = Get-TargetResource @testParametersPresent
                $getTargetResourceResult.Ensure | Should -Be 'Absent'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsOnlineResponder `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When there is an unexpected error' {
        BeforeAll {
            Mock `
                -CommandName Install-AdcsOnlineResponder `
                -MockWith { Throw (New-Object -TypeName 'System.Exception') } `
                -Verifiable
        }

        It 'Should throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Get-TargetResource @testParametersPresent } | Should -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsOnlineResponder `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsOnlineResponder\Set-TargetResource' -Tag 'Set' {
    Context 'When the Online Responder is not installed but should be' {
        BeforeAll {
            Mock -CommandName Install-AdcsOnlineResponder
            Mock -CommandName Uninstall-AdcsOnlineResponder
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @testParametersPresent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsOnlineResponder `
                -Exactly `
                -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsOnlineResponder `
                -Exactly `
                -Times 0 -Scope Context
        }
    }

    Context 'When the Online Responder is not installed but should be but an error is thrown installing it' {
        BeforeAll {
            Mock -CommandName Install-AdcsOnlineResponder `
                -MockWith { [PSObject] @{ ErrorString = 'Something went wrong' } }

            Mock -CommandName Uninstall-AdcsOnlineResponder
        }

        It 'Should throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                { Set-TargetResource @testParametersPresent } | Should -Throw $errorRecord
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsOnlineResponder `
                -Exactly `
                -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsOnlineResponder `
                -Exactly `
                -Times 0 -Scope Context
        }
    }

    Context 'When the Online Responder is installed but should not be' {
        BeforeAll {
            Mock -CommandName Install-AdcsOnlineResponder
            Mock -CommandName Uninstall-AdcsOnlineResponder
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @TestParametersAbsent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsOnlineResponder `
                -Exactly `
                -Times 0 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsOnlineResponder `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsOnlineResponder\Test-TargetResource' -Tag 'Test' {
    Context 'When the Online Responder is installed' {
        Context 'When the Online Responder should be installed' {
            BeforeAll {
                Mock -CommandName Install-AdcsOnlineResponder `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                    -Verifiable
            }

            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testTargetResourceResult = Test-TargetResource @testParametersPresent
                    $testTargetResourceResult | Should -BeTrue
                }
            }

            It 'Should call expected mocks' {
                Should -InvokeVerifiable
                Should -Invoke `
                    -CommandName Install-AdcsOnlineResponder `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }

        Context 'When the Online Responder should not be installed' {
            BeforeAll {
                Mock -CommandName Install-AdcsOnlineResponder `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException') } `
                    -Verifiable
            }


            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testTargetResourceResult = Test-TargetResource @TestParametersAbsent
                    $testTargetResourceResult | Should -BeFalse
                }
            }

            It 'Should call expected mocks' {
                Should -InvokeVerifiable
                Should -Invoke `
                    -CommandName Install-AdcsOnlineResponder `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }
    }

    Context 'When the Online Responder is not installed' {
        Context 'When the Online Responder should be installed' {
            BeforeAll {
                Mock -CommandName Install-AdcsOnlineResponder `
                    -Verifiable
            }

            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testTargetResourceResult = Test-TargetResource @testParametersPresent
                    $testTargetResourceResult | Should -BeFalse
                }
            }

            It 'Should call expected mocks' {
                Should -InvokeVerifiable
                Should -Invoke `
                    -CommandName Install-AdcsOnlineResponder `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }

        Context 'When the Online Responder should not be installed' {
            BeforeAll {
                Mock -CommandName Install-AdcsOnlineResponder `
                    -Verifiable
            }


            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testTargetResourceResult = Test-TargetResource @TestParametersAbsent
                    $testTargetResourceResult | Should -BeTrue
                }
            }

            It 'Should call expected mocks' {
                Should -InvokeVerifiable
                Should -Invoke `
                    -CommandName Install-AdcsOnlineResponder `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }
    }

    Context 'Should throw on any other error' {
        BeforeAll {
            Mock -CommandName Install-AdcsOnlineResponder `
                -MockWith { Throw (New-Object -TypeName 'System.Exception') } `
                -Verifiable
        }

        It 'Should throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Test-TargetResource @testParametersPresent } | Should -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsOnlineResponder `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}
