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

                    $script:mockCredential = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))

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
                        Credential       = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))
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

                    $script:mockCredential = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))

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

                    $script:mockCredential = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))

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

Describe 'AdcsOnlineResponder\Set()' -Tag 'Set'{
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockCredential = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))

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

            $script:mockCredential = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))

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

Describe 'AdcsOnlineResponder\GetCurrentState()' -Tag 'HiddenMember' -Skip:$true {
    Context 'When object is missing in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                    AiaUri           = @('http://example.com/aia1')
                    OcspUri          = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                }
            }

            Mock -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateAia'
            }

            Mock -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateOcsp'
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

                $currentState.IsSingleInstance | Should -BeNullOrEmpty
                $currentState.AiaUri | Should -BeNullOrEmpty
                $currentState.OcspUri | Should -BeNullOrEmpty
                $currentState.AllowRestartService | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateAia'
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateOcsp'
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the object is present in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                    AiaUri           = @('http://example.com/aia1')
                    OcspUri          = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                }
            }

            Mock -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateAia'
            } -MockWith {
                return @('http://example.com/aia1', 'http://example.com/aia2')
            }

            Mock -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateOcsp'
            } -MockWith {
                return @('http://example.com/ocsp1', 'http://example.com/ocsp2')
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
                $currentState.AiaUri | Should -Be @('http://example.com/aia1', 'http://example.com/aia2')
                $currentState.OcspUri | Should -Be @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                $currentState.AllowRestartService | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateAia'
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Get-CaAiaUriList -ParameterFilter {
                $ExtensionType -eq 'AddToCertificateOcsp'
            } -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'AdcsOnlineResponder\Modify()' -Tag 'HiddenMember' -Skip:$true {
    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [AdcsOnlineResponder] @{
                    IsSingleInstance = 'Yes'
                    AiaUri           = @('http://example.com/aia1', 'http://example.com/aia2')
                    OcspUri          = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                }

                Mock -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                }

                Mock -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                }

                Mock -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                }

                Mock -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                }

                Mock -CommandName Restart-ServiceIfExists
            }
        }

        Context 'When the resource does not exist' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        AiaUri  = @('http://example.com/aia1', 'http://example.com/aia2')
                        OcspUri = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                    }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'AiaUri'
                            ExpectedValue = @('http://example.com/aia1', 'http://example.com/aia2')
                            ActualValue   = @()
                        }
                        @{
                            Property      = 'OcspUri'
                            ExpectedValue = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                            ActualValue   = @()
                        }
                    )

                    $script:mockInstance.Modify($mockProperties)
                }

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 2 -Scope It

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 2 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It
            }
        }

        Context 'When the AIA needs to be added' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        AiaUri = @('http://example.com/aia1', 'http://example.com/aia2')
                    }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'AiaUri'
                            ExpectedValue = @('http://example.com/aia1', 'http://example.com/aia2')
                            ActualValue   = @('http://example.com/aia1')
                        }
                    )

                    $script:mockInstance.Modify($mockProperties)
                }

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It
            }
        }

        Context 'When the OCSP needs to be added' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        OcspUri = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                    }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'OcspUri'
                            ExpectedValue = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                            ActualValue   = @('http://example.com/ocsp1')
                        }
                    )

                    $script:mockInstance.Modify($mockProperties)
                }

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It
            }
        }

        Context 'When the AIA needs to be removed' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        AiaUri = @('http://example.com/aia1', 'http://example.com/aia2')
                    }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'AiaUri'
                            ExpectedValue = @('http://example.com/aia1')
                            ActualValue   = @('http://example.com/aia1', 'http://example.com/aia2')
                        }

                    )

                    $script:mockInstance.Modify($mockProperties)
                }

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It
            }
        }

        Context 'When the OCSP needs to be removed' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        OcspUri = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                    }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'OcspUri'
                            ExpectedValue = @('http://example.com/ocsp1')
                            ActualValue   = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                        }
                    )

                    $script:mockInstance.Modify($mockProperties)
                }

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It
            }
        }

        Context 'When the OCSP needs to be removed and AllowRestartService is set to $true' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        OcspUri = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                    }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'OcspUri'
                            ExpectedValue = @('http://example.com/ocsp1')
                            ActualValue   = @('http://example.com/ocsp1', 'http://example.com/ocsp2')
                        }
                    )

                    $script:mockInstance.AllowRestartService = $true

                    $script:mockInstance.Modify($mockProperties)
                }

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Add-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateAia -eq $true
                } -Exactly -Times 0 -Scope It

                Should -Invoke -CommandName Remove-CAAuthorityInformationAccess -ParameterFilter {
                    $AddToCertificateOcsp -eq $true
                } -Exactly -Times 1 -Scope It

                Should -Invoke -CommandName Restart-ServiceIfExists -Exactly -Times 1 -Scope It
            }
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

                { $mockInstance.AssertProperties($mockProperties) } | Should -Throw
            }
        }
    }

    Context 'When required module is present' {
        BeforeAll {
            Mock -CommandName Assert-Module
        }

        It 'Should throw an error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockProperties = @{
                    IsSingleInstance = 'Yes'
                }

                { $mockInstance.AssertProperties($mockProperties) } | Should -Not -Throw
            }
        }
    }
}
