<#
    .SYNOPSIS
        Unit test for DSC_AdcsTemplate DSC resource.

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
    $script:dscResourceName = 'DSC_AdcsTemplate'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\AdcsStub.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\Stubs\AdcsAdministrationStub.psm1')


    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName
}


AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    Remove-Module -Name AdcsStub -Force
    Remove-Module -Name AdcsAdministrationStub -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe 'DSC_AdcsTemplate\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        $script:mockTemplateList = @(
            @{
                Name = 'User'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.1'
            }
            @{
                Name = 'DirectoryEmailReplication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.29'
            }
            @{
                Name = 'DomainControllerAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.28'
            }
            @{
                Name = 'KerberosAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.33'
            }
        )
    }
    Context 'When the template is installed' {
        BeforeAll {
            Mock -CommandName Get-CATemplate -MockWith { $mockTemplateList }
        }

        It 'Should return Ensure set to Present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceParameters = @{
                    Name = 'User'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                $getTargetResourceResult.Ensure | Should -Be 'Present'
            }
        }

        It 'Should call expected mocks' {
            #Should -InvokeVerifiable
            Should -Invoke -CommandName Get-CATemplate -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When the template is not installed' {
        BeforeAll {
            Mock -CommandName Get-CATemplate -MockWith { $mockTemplateList }
        }

        It 'Should return Ensure set to Absent' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceParameters = @{
                    Name = 'EFS'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                $getTargetResourceResult.Ensure | Should -Be 'Absent'
            }
        }

        It 'Should call expected mocks' {
            #Should -InvokeVerifiable
            Should -Invoke -CommandName Get-CATemplate -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When Get-CATemplate throws an exception' {
        BeforeEach {
            Mock -CommandName Get-CATemplate -MockWith { throw }
        }

        It 'Should throw the correct error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceParameters = @{
                    Name = 'User'
                }

                $mockErrorRecord = Get-InvalidOperationRecord `
                    -Message $script:localizedData.InvalidOperationGettingAdcsTemplateMessage

                { Get-TargetResource @getTargetResourceParameters } | Should -Throw -ExpectedMessage ($mockErrorRecord.Exception.Message + '*')
            }
        }
    }
}

Describe 'DSC_AdcsTemplate\Set-TargetResource' -Tag 'Set' {
    Context 'When the template is not added but should be' {
        BeforeAll {
            Mock -CommandName Add-CATemplate

            InModuleScope -ScriptBlock {
                # TODO: Make this work inside and outside of `InModuleScope`
                $script:testTemplateNotPresent = @{
                    Name = 'EFS'
                }
            }
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $setTargetResourceParameters = $testTemplateNotPresent

                { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
            }
        }

        It 'Should call expected mock' {
            Should -Invoke -CommandName Add-CATemplate `
                -ParameterFilter {
                # TODO Fix this hardocded
                $Name -eq 'EFS'
            } -Exactly -Times 1 -Scope Context
        }

        Context 'When Add-CATemplate throws an exception' {
            BeforeAll {
                Mock -CommandName Add-CATemplate -MockWith { throw }
            }

            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testTemplateNotPresent = @{
                        Name = 'EFS'
                    }

                    $mockErrorRecord = Get-InvalidOperationRecord `
                        -Message ($script:localizedData.InvalidOperationAddingAdcsTemplateMessage -f $testTemplateNotPresent.Name)

                    { Set-TargetResource @testTemplateNotPresent } | Should -Throw -ExpectedMessage ($mockErrorRecord.Exception.Message + '*')
                }
            }
        }

        Context 'When the template is added but should not be' {
            BeforeAll {
                Mock -CommandName Remove-CATemplate
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testTemplatePresent = @{
                        Name = 'User'
                    }

                    { Set-TargetResource @testTemplatePresent -Ensure 'Absent' } | Should -Not -Throw
                }
            }

            It 'Should call expected mock' {
                Should -Invoke `
                    -CommandName Remove-CATemplate `
                    -ParameterFilter {
                    $Name -eq 'User'
                } -Exactly -Times 1 -Scope Context

            }
        }

        Context 'When Remove-CATemplate throws an exception' {
            BeforeAll {
                Mock -CommandName Remove-CATemplate -MockWith { throw }
            }

            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testTemplatePresent = @{
                        Name = 'User'
                    }

                    $mockErrorRecord = Get-InvalidOperationRecord `
                        -Message ($script:localizedData.InvalidOperationRemovingAdcsTemplateMessage -f $testTemplatePresent.Name)

                    { Set-TargetResource @testTemplatePresent -Ensure 'Absent' } | Should -Throw -ExpectedMessage ($mockErrorRecord.Exception.Message + '*')
                }
            }
        }
    }
}

Describe 'DSC_AdcsTemplate\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        $script:mockGetTemplatePresent = @{
            Name   = 'User'
            Ensure = 'Present'
        }

        $script:mockGetTemplateNotPresent = @{
            Name   = 'EFS'
            Ensure = 'Absent'
        }
    }
    Context 'When the template is added and should be' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { $mockGetTemplatePresent }
        }
        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockTestTargetResourceParameters = @{
                    Name = 'User'
                }

                $testTargetResourceResult = Test-TargetResource @mockTestTargetResourceParameters -Ensure 'Present'
                $testTargetResourceResult | Should -BeTrue
            }
        }

        It 'Should call expected mock' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -ParameterFilter {
                $Name -eq 'User'
            } -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When the template is added and should not be' {
        BeforeAll {
            Mock -CommandName Get-TargetResource `
                -MockWith { $mockGetTemplatePresent }

        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockTestTargetResourceParameters = @{
                    Name = 'EFS'
                }
                $testTargetResourceResult = Test-TargetResource @mockTestTargetResourceParameters -Ensure 'Absent'
                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call expected mock' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -ParameterFilter {
                $Name -eq 'EFS'
            } -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When the template is not added and should be' {
        BeforeAll {
            Mock -CommandName Get-TargetResource `
                -MockWith { $mockGetTemplateNotPresent }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockTestTargetResourceParameters = @{
                    Name = 'EFS'
                }

                $testTargetResourceResult = Test-TargetResource @mockTestTargetResourceParameters -Ensure 'Present'
                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call expected mock' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -ParameterFilter {
                $Name -eq 'EFS'
            } -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When the template is not added and should not be' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { $MockGetTemplateNotPresent }

        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockTestTargetResourceParameters = @{
                    Name = 'EFS'
                }
                $testTargetResourceResult = Test-TargetResource @mockTestTargetResourceParameters -Ensure 'Absent'
                $testTargetResourceResult | Should -BeTrue
            }
        }

        It 'Should call expected mock' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -ParameterFilter {
                $Name -eq 'EFS'
            } -Exactly -Times 1 -Scope Context
        }
    }
}
