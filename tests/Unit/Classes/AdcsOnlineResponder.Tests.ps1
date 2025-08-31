<#
    .SYNOPSIS
        Unit test for AdcsOnlineResponder DSC resource.
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
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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

    # Loading mocked exception class
    # New-MockObject -Type Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException

    Import-Module -Name $script:dscModuleName

    # Load stub cmdlets and classes.
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\Stubs\AdcsDeploymentStub.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload stub module
    Remove-Module -Name AdcsDeploymentStub -Force

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'AdcsOnlineResponder' {
    Context 'When class is instantiated' {
        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [AdcsOnlineResponder]::new() } | Should -Not -Throw
            }
        }

        It 'Should have a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [AdcsOnlineResponder]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should be the correct type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [AdcsOnlineResponder]::new()
                $instance.GetType().Name | Should -Be 'AdcsOnlineResponder'
            }
        }
    }
}

Describe 'AdcsOnlineResponder\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        Context 'When AdcsOnlineResponder is installed' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockCredential = [System.Management.Automation.PSCredential]::new('Administrator', ([System.Security.SecureString]::new()))

                    $script:mockInstance = [AdcsOnlineResponder] @{
                        IsSingleInstance = 'Yes'
                        Credential       = $script:mockCredential
                    }

                    <#
                        This mocks the method GetCurrentState().
                        This mocks the method Assert().
                        This mocks the method Normalize().

                        Method Get() will call the base method Get() which will
                        call back to the derived class methods.
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                IsSingleInstance = 'Yes'
                                Credential       = $script:mockCredential
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.Credential | Should -Be $script:mockCredential
                    $currentState.Ensure | Should -Be 'Present'

                    $currentState.Reasons | Should -BeNullOrEmpty
                }
            }
        }

        Context 'When AdcsOnlineResponder is not installed' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [AdcsOnlineResponder] @{
                        IsSingleInstance = 'Yes'
                        Credential       = [System.Management.Automation.PSCredential]::new('Administrator', ([System.Security.SecureString]::new()))
                        Ensure           = [Ensure]::Absent
                    }

                    <#
                        This mocks the method GetCurrentState().
                        This mocks the method Assert().
                        This mocks the method Normalize().

                        Method Get() will call the base method Get() which will
                        call back to the derived class methods.
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{}
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.Credential | Should -BeNullOrEmpty
                    $currentState.Ensure | Should -Be 'Absent'

                    $currentState.Reasons | Should -HaveCount 0
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When AdcsOnlineResponder is installed' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockCredential = [System.Management.Automation.PSCredential]::new('Administrator', ([System.Security.SecureString]::new()))

                    $script:mockInstance = [AdcsOnlineResponder] @{
                        IsSingleInstance = 'Yes'
                        Credential       = $script:mockCredential
                        Ensure           = [Ensure]::Absent
                    }

                    <#
                        This mocks the method GetCurrentState().
                        This mocks the method Assert().
                        This mocks the method Normalize().

                        Method Get() will call the base method Get() which will
                        call back to the derived class methods.
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                IsSingleInstance = 'Yes'
                                Credential       = $script:mockCredential
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.Credential | Should -Be $script:mockCredential
                    $currentState.Ensure | Should -Be 'Present'


                    $currentState.Reasons | Should -HaveCount 1
                    $currentState.Reasons[0].Code | Should -Be 'AdcsOnlineResponder:AdcsOnlineResponder:Ensure'
                    $currentState.Reasons[0].Phrase | Should -Be 'The property Ensure should be "Absent", but was "Present"'
                }
            }
        }

        Context 'When AdcsOnlineResponder is not installed' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockCredential = [System.Management.Automation.PSCredential]::new('Administrator', ([System.Security.SecureString]::new()))

                    $script:mockInstance = [AdcsOnlineResponder] @{
                        IsSingleInstance = 'Yes'
                        Credential       = $script:mockCredential
                    }

                    <#
                        This mocks the method GetCurrentState().
                        This mocks the method Assert().
                        This mocks the method Normalize().

                        Method Get() will call the base method Get() which will
                        call back to the derived class methods.
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{}
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.IsSingleInstance | Should -Be 'Yes'

                    $currentState.Credential | Should -BeNullOrEmpty
                    $currentState.Ensure | Should -Be 'Absent'


                    $currentState.Reasons | Should -HaveCount 1
                    $currentState.Reasons[0].Code | Should -Be 'AdcsOnlineResponder:AdcsOnlineResponder:Ensure'
                    $currentState.Reasons[0].Phrase | Should -Be 'The property Ensure should be "Present", but was "Absent"'
                }
            }
        }
    }
}

Describe 'AdcsOnlineResponder\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockCredential = [System.Management.Automation.PSCredential]::new('Administrator', ([System.Security.SecureString]::new()))

            $script:mockInstance = [AdcsOnlineResponder] @{
                IsSingleInstance = 'Yes'
                Credential       = $script:mockCredential
            } |
                # Mock method Modify which is called by the case method Set().
                Add-Member -Force -MemberType 'ScriptMethod' -Name 'Modify' -Value {
                    $script:methodModifyCallCount += 1
                } -PassThru
        }
    }

    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:methodTestCallCount = 0
            $script:methodModifyCallCount = 0
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:methodTestCallCount += 1
                        return $true
                    }

            }
        }

        It 'Should not call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Set()

                $script:methodTestCallCount | Should -Be 1
                $script:methodModifyCallCount | Should -Be 0
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:methodTestCallCount += 1
                        return $false
                    }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'Ensure'
                        ExpectedValue = 'Present'
                        ActualValue   = 'Absent'
                    }
                )
            }
        }

        It 'Should call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Set()

                $script:methodTestCallCount | Should -Be 1
                $script:methodModifyCallCount | Should -Be 1
            }
        }
    }
}

Describe 'AdcsOnlineResponder\Test()' -Tag 'Test' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockCredential = [System.Management.Automation.PSCredential]::new('Administrator', ([System.Security.SecureString]::new()))

            $script:mockInstance = [AdcsOnlineResponder] @{
                IsSingleInstance = 'Yes'
                Credential       = $script:mockCredential
            }
        }
    }

    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:getMethodCallCount = 0
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Get() which is called by the base method Test()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                        $script:getMethodCallCount += 1
                    }
            }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeTrue

                $script:getMethodCallCount | Should -Be 1
            }
        }

    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Get() which is called by the base method Test()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                        $script:getMethodCallCount += 1
                    }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'Ensure'
                        ExpectedValue = 'Present'
                        ActualValue   = 'Absent'
                    }
                )
            }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeFalse

                $script:getMethodCallCount | Should -Be 1
            }
        }
    }
}

Describe 'AdcsOnlineResponder\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When the OnlineResponder is not installed' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                    Ensure           = [Ensure]::Present
                }
            }

            Mock -CommandName Install-AdcsOnlineResponder
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        IsSingleInstance = 'Yes'
                    }
                )

                $currentState.IsSingleInstance | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Install-AdcsOnlineResponder -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the OnlineResponder is already installed' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                    Ensure           = [Ensure]::Present
                }
            }

            Mock -CommandName Install-AdcsOnlineResponder -MockWith {
                throw [Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException]::new()
            }
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        IsSingleInstance = 'Yes'
                    }
                )

                $currentState.IsSingleInstance | Should -Be 'Yes'
            }

            Should -Invoke -CommandName Install-AdcsOnlineResponder -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the OnlineResponder throws an unexpected exception' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                    Ensure           = [Ensure]::Present
                }
            }

            Mock -CommandName Install-AdcsOnlineResponder -MockWith {
                throw 'Another exception'
            }
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $errorRecord = Get-InvalidOperationRecord -Message $script:mockInstance.localizedData.ErrorGetCurrentState

                {
                    $script:mockInstance.GetCurrentState(
                        @{
                            IsSingleInstance = 'Yes'
                        }
                    )
                } | Should -Throw -ExpectedMessage ($errorRecord.Exception.Message + '*')
            }

            Should -Invoke -CommandName Install-AdcsOnlineResponder -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'AdcsOnlineResponder\Modify()' -Tag 'HiddenMember' {
    Context 'When the resource should be added' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                }

                Mock -CommandName Install-AdcsOnlineResponder
            }
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockProperties = @{
                    Ensure = [Ensure]::Present
                }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'Ensure'
                        ExpectedValue = 'Present'
                        ActualValue   = 'Absent'
                    }
                )

                { $script:mockInstance.Modify($mockProperties) } | Should -Not -Throw
            }

            Should -Invoke -CommandName Install-AdcsOnlineResponder -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource should be added and fails' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                }

                Mock -CommandName Install-AdcsOnlineResponder -MockWith { throw }
            }
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockProperties = @{
                    Ensure = [Ensure]::Present
                }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'Ensure'
                        ExpectedValue = 'Present'
                        ActualValue   = 'Absent'
                    }
                )

                { $script:mockInstance.Modify($mockProperties) } | Should -Throw
            }

            Should -Invoke -CommandName Install-AdcsOnlineResponder -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource should be removed' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                }

                Mock -CommandName Uninstall-AdcsOnlineResponder
            }
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockProperties = @{
                    Ensure = [Ensure]::Absent
                }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'Ensure'
                        ExpectedValue = 'Absent'
                        ActualValue   = 'Present'
                    }
                )

                { $script:mockInstance.Modify($mockProperties) } | Should -Not -Throw
            }

            Should -Invoke -CommandName Uninstall-AdcsOnlineResponder -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource should be removed but fails' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                }

                Mock -CommandName Uninstall-AdcsOnlineResponder -MockWith { throw }
            }
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockProperties = @{
                    Ensure = [Ensure]::Absent
                }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'Ensure'
                        ExpectedValue = 'Absent'
                        ActualValue   = 'Present'
                    }
                )

                { $script:mockInstance.Modify($mockProperties) } | Should -Throw
            }

            Should -Invoke -CommandName Uninstall-AdcsOnlineResponder -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'AdcsOnlineResponder\AssertProperties()' -Tag 'AssertProperties' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [AdcsOnlineResponder] @{}
        }
    }

    Context 'When required module is missing' {
        BeforeAll {
            Mock -CommandName Assert-Module -MockWith { throw }
        }

        It 'Should throw an error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockProperties = @{
                    IsSingleInstance = 'Yes'
                }

                { $script:mockInstance.AssertProperties($mockProperties) } | Should -Throw
            }
        }
    }

    Context 'When required module is present' {
        BeforeAll {
            Mock -CommandName Assert-Module
        }

        It 'Should not throw an error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockProperties = @{
                    IsSingleInstance = 'Yes'
                }

                { $script:mockInstance.AssertProperties($mockProperties) } | Should -Not -Throw
            }
        }
    }
}
