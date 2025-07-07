<#
    .SYNOPSIS
        Unit test for AdcsAuthorityInformationAccess DSC resource.
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

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'AdcsAuthorityInformationAccess' {
    Context 'When class is instantiated' {
        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [AdcsAuthorityInformationAccess]::new() } | Should -Not -Throw
            }
        }

        It 'Should have a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [AdcsAuthorityInformationAccess]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should be the correct type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [AdcsAuthorityInformationAccess]::new()
                $instance.GetType().Name | Should -Be 'AdcsAuthorityInformationAccess'
            }
        }
    }
}

Describe 'WSManListener\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        Context 'When getting AIA and OCSP URIs' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [AdcsAuthorityInformationAccess] @{
                        IsSingleInstance = 'Yes'
                        AiaUri           = 'http://example.com/aia'
                        OcspUri          = 'http://example.com/ocsp'
                        Ensure           = 'Present'
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
                                AiaUri           = [System.String[]] 'http://example.com/aia'
                                OcspUri          = [System.String[]] 'http://example.com/ocsp'
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

                    $currentState.AiaUri | Should -Be @('http://example.com/aia')
                    $currentState.OcspUri | Should -Be @('http://example.com/ocsp')

                    $currentState.AllowRestartService | Should -BeNullOrEmpty

                    $currentState.Ensure | Should -Be 'Present'
                    $currentState.Reasons | Should -BeNullOrEmpty
                }
            }
        }

        Context 'When no URIs should exist' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [AdcsAuthorityInformationAccess] @{
                        IsSingleInstance = 'Yes'
                        Ensure           = 'Absent'
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

                    $currentState.AiaUri | Should -BeNullOrEmpty
                    $currentState.OcspUri | Should -BeNullOrEmpty

                    $currentState.AllowRestartService | Should -BeNullOrEmpty

                    $currentState.Ensure | Should -Be 'Absent'
                    $currentState.Reasons | Should -HaveCount 0
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property ''AiaUri'' has the wrong value' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [AdcsAuthorityInformationAccess] @{
                        IsSingleInstance = 'HTTPS'
                        AiaUri           = 'http://example.com/aia'
                        OcspUri          = 'http://example.com/ocsp'
                        Ensure           = 'Present'
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
                                AiaUri           = [System.String[]] 'http://example.com/aiaincorrect'
                                OcspUri          = [System.String[]] 'http://example.com/ocsp'
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

                    $currentState.AiaUri | Should -Be @('http://example.com/aiaincorrect')
                    $currentState.OcspUri | Should -Be @('http://example.com/ocsp')

                    $currentState.AllowRestartService | Should -BeNullOrEmpty

                    $currentState.Ensure | Should -Be 'Present'

                    $currentState.Reasons | Should -HaveCount 1
                    $currentState.Reasons[0].Code | Should -Be 'AdcsAuthorityInformationAccess:AdcsAuthorityInformationAccess:AiaUri'
                    $currentState.Reasons[0].Phrase | Should -Be 'The property AiaUri should be "http://example.com/aia", but was "http://example.com/aiaincorrect"'
                }
            }
        }

        Context 'When the listener exists but should not' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [WSManListener] @{
                        Transport = 'HTTP'
                        Ensure    = 'Absent'
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
                            return [System.Collections.Hashtable] @{
                                Transport             = [WSManTransport] 'HTTP'
                                Port                  = [System.UInt16] 5985
                                Address               = '*'
                                Enabled               = 'true'
                                URLPrefix             = 'wsman'
                                Issuer                = $null
                                MatchAlternate        = $null
                                BaseDN                = $null
                                CertificateThumbprint = $null
                                Hostname              = $null
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

                    $currentState.Transport | Should -Be 'HTTP'
                    $currentState.Port | Should -Be 5985

                    $currentState.Address | Should -Be '*'
                    $currentState.Enabled | Should -BeTrue
                    $currentState.URLPrefix | Should -Be 'wsman'

                    $currentState.Issuer | Should -BeNullOrEmpty
                    $currentState.SubjectFormat | Should -Be 0
                    $currentState.MatchAlternate | Should -BeNullOrEmpty
                    $currentState.BaseDN | Should -BeNullOrEmpty
                    $currentState.CertificateThumbprint | Should -BeNullOrEmpty
                    $currentState.Hostname | Should -BeNullOrEmpty

                    $currentState.Ensure | Should -Be 'Present'

                    $currentState.Reasons | Should -HaveCount 1
                    $currentState.Reasons[0].Code | Should -Be 'WSManListener:WSManListener:Ensure'
                    $currentState.Reasons[0].Phrase | Should -Be 'The property Ensure should be "Absent", but was "Present"'
                }
            }
        }
    }
}

# Describe 'WSManListener\Set()' -Tag 'Set' {
#     BeforeAll {
#         InModuleScope -ScriptBlock {
#             Set-StrictMode -Version 1.0

#             $script:mockInstance = [WSManListener] @{
#                 Transport = 'HTTP'
#                 Port      = 5000
#                 Ensure    = 'Present'
#             } |
#                 # Mock method Modify which is called by the case method Set().
#                 Add-Member -Force -MemberType 'ScriptMethod' -Name 'Modify' -Value {
#                     $script:methodModifyCallCount += 1
#                 } -PassThru
#         }
#     }

#     BeforeEach {
#         InModuleScope -ScriptBlock {
#             Set-StrictMode -Version 1.0

#             $script:methodTestCallCount = 0
#             $script:methodModifyCallCount = 0
#         }
#     }

#     Context 'When the system is in the desired state' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance |
#                     # Mock method Test() which is called by the base method Set()
#                     Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
#                         $script:methodTestCallCount += 1
#                         return $true
#                     }

#             }
#         }

#         It 'Should not call method Modify()' {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance.Set()

#                 $script:methodTestCallCount | Should -Be 1
#                 $script:methodModifyCallCount | Should -Be 0
#             }
#         }
#     }

#     Context 'When the system is not in the desired state' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance |
#                     # Mock method Test() which is called by the base method Set()
#                     Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
#                         $script:methodTestCallCount += 1
#                         return $false
#                     }

#                 $script:mockInstance.PropertiesNotInDesiredState = @(
#                     @{
#                         Property      = 'Port'
#                         ExpectedValue = 5000
#                         ActualValue   = 5985
#                     }
#                 )
#             }
#         }

#         It 'Should call method Modify()' {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance.Set()

#                 $script:methodTestCallCount | Should -Be 1
#                 $script:methodModifyCallCount | Should -Be 1
#             }
#         }
#     }
# }

# Describe 'WSManListener\Test()' -Tag 'Test' {
#     BeforeAll {
#         InModuleScope -ScriptBlock {
#             Set-StrictMode -Version 1.0

#             $script:mockInstance = [WSManListener] @{
#                 Transport             = 'HTTPS'
#                 Port                  = 5986
#                 CertificateThumbprint = '74FA31ADEA7FDD5333CED10910BFA6F665A1F2FC'
#                 Hostname              = [System.Net.Dns]::GetHostEntry((Get-ComputerName)).Hostname
#                 Ensure                = 'Present'
#             }
#         }
#     }

#     BeforeEach {
#         InModuleScope -ScriptBlock {
#             Set-StrictMode -Version 1.0

#             $script:getMethodCallCount = 0
#         }
#     }

#     Context 'When the system is in the desired state' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance |
#                     # Mock method Get() which is called by the base method Test()
#                     Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
#                         $script:getMethodCallCount += 1
#                     }
#             }

#             It 'Should return $true' {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $script:mockInstance.Test() | Should -BeTrue

#                     $script:getMethodCallCount | Should -Be 1
#                 }
#             }
#         }
#     }

#     Context 'When the system is not in the desired state' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance |
#                     # Mock method Get() which is called by the base method Test()
#                     Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
#                         $script:getMethodCallCount += 1
#                     }

#                 $script:mockInstance.PropertiesNotInDesiredState = @(
#                     @{
#                         Property      = 'Port'
#                         ExpectedValue = 5986
#                         ActualValue   = 443
#                     }
#                 )
#             }
#         }

#         It 'Should return $false' {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance.Test() | Should -BeFalse

#                 $script:getMethodCallCount | Should -Be 1
#             }
#         }
#     }
# }

# Describe 'WSManListener\GetCurrentState()' -Tag 'HiddenMember' {
#     Context 'When object is missing in the current state' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance = [WSManListener] @{
#                     Transport = 'HTTP'
#                     Port      = 5985
#                     Address   = '*'
#                     Ensure    = 'Present'
#                 }
#             }

#             Mock -CommandName Get-Listener
#         }

#         It 'Should return the correct values' {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $currentState = $script:mockInstance.GetCurrentState(
#                     @{
#                         Transport = 'HTTP'
#                         Ensure    = [Ensure]::Present
#                     }
#                 )

#                 $currentState.Transport | Should -BeNullOrEmpty
#                 $currentState.Port | Should -BeNullOrEmpty
#                 $currentState.Address | Should -BeNullOrEmpty
#                 $currentState.Issuer | Should -BeNullOrEmpty
#                 $currentState.CertificateThumbprint | Should -BeNullOrEmpty
#                 $currentState.Hostname | Should -BeNullOrEmpty
#                 $currentState.Enabled | Should -BeFalse
#                 $currentState.URLPrefix | Should -BeNullOrEmpty
#             }

#             Should -Invoke -CommandName Get-Listener -Exactly -Times 1 -Scope It
#         }
#     }

#     Context 'When the object is present in the current state' {
#         Context 'When getting a HTTP Transport' {
#             BeforeAll {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $script:mockInstance = [WSManListener] @{
#                         Transport = 'HTTP'
#                         Port      = 5985
#                         Address   = '*'
#                         Ensure    = 'Present'
#                     }
#                 }

#                 Mock -CommandName Get-Listener -MockWith {
#                     return @{
#                         Transport             = 'HTTP'
#                         Port                  = [System.UInt16] 5985
#                         Address               = '*'

#                         CertificateThumbprint = $null
#                         Hostname              = [System.Net.Dns]::GetHostEntry((Get-ComputerName)).Hostname

#                         Enabled               = $true
#                         URLPrefix             = 'wsman'
#                     }
#                 }
#             }

#             It 'Should return the correct values' {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $currentState = $script:mockInstance.GetCurrentState(
#                         @{
#                             Transport = 'HTTP'
#                             Ensure    = [Ensure]::Present
#                         }
#                     )

#                     $currentState.Transport | Should -Be 'HTTP'
#                     $currentState.Port | Should -Be 5985
#                     $currentState.Address | Should -Be '*'
#                     $currentState.Issuer | Should -BeNullOrEmpty
#                     $currentState.CertificateThumbprint | Should -BeNullOrEmpty
#                     $currentState.Hostname | Should -Be ([System.Net.Dns]::GetHostEntry((Get-ComputerName)).Hostname)
#                     $currentState.Enabled | Should -BeTrue
#                     $currentState.URLPrefix | Should -Be 'wsman'
#                 }

#                 Should -Invoke -CommandName Get-Listener -Exactly -Times 1 -Scope It
#             }
#         }

#         Context 'When getting a HTTPS Transport' {
#             BeforeAll {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $script:mockInstance = [WSManListener] @{
#                         Transport = 'HTTPS'
#                         Port      = 5986
#                         Address   = '*'
#                         Ensure    = 'Present'
#                     }
#                 }

#                 Mock -CommandName Get-Listener -MockWith {
#                     return @{
#                         Transport             = 'HTTPS'
#                         Port                  = [System.UInt16] 5986
#                         Address               = '*'

#                         CertificateThumbprint = '74FA31ADEA7FDD5333CED10910BFA6F665A1F2FC'
#                         Hostname              = [System.Net.Dns]::GetHostEntry((Get-ComputerName)).Hostname

#                         Enabled               = $true
#                         URLPrefix             = 'wsman'
#                     }
#                 }

#                 Mock -CommandName Find-Certificate -MockWith {
#                     return @{ Issuer = 'CN=CONTOSO.COM Issuing CA, DC=CONTOSO, DC=COM' }
#                 }
#             }

#             It 'Should return the correct values' {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $currentState = $script:mockInstance.GetCurrentState(
#                         @{
#                             Transport = 'HTTPS'
#                             Ensure    = [Ensure]::Present
#                         }
#                     )

#                     $currentState.Transport | Should -Be 'HTTPS'
#                     $currentState.Port | Should -Be 5986
#                     $currentState.Address | Should -Be '*'
#                     $currentState.Issuer | Should -Be 'CN=CONTOSO.COM Issuing CA, DC=CONTOSO, DC=COM'
#                     $currentState.CertificateThumbprint | Should -Be '74FA31ADEA7FDD5333CED10910BFA6F665A1F2FC'
#                     $currentState.Hostname | Should -Be ([System.Net.Dns]::GetHostEntry((Get-ComputerName)).Hostname)
#                     $currentState.Enabled | Should -BeTrue
#                     $currentState.URLPrefix | Should -Be 'wsman'
#                 }

#                 Should -Invoke -CommandName Get-Listener -Exactly -Times 1 -Scope It
#                 Should -Invoke -CommandName Find-Certificate -Exactly -Times 1 -Scope It
#             }
#         }
#     }
# }

# Describe 'WSManListener\Modify()' -Tag 'HiddenMember' {
#     Context 'When the system is not in the desired state' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance = [WSManListener] @{
#                     Transport = 'HTTP'
#                     Ensure    = 'Present'
#                 } |
#                     # Mock method NewInstance which is called by the case method Modify().
#                     Add-Member -Force -MemberType 'ScriptMethod' -Name 'NewInstance' -Value {
#                         $script:methodNewInstanceCallCount += 1
#                     } -PassThru |
#                     # Mock method RemoveInstance which is called by the case method Modify().
#                     Add-Member -Force -MemberType 'ScriptMethod' -Name 'RemoveInstance' -Value {
#                         $script:methodRemoveInstanceCallCount += 1
#                     } -PassThru
#             }
#         }

#         BeforeEach {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:methodNewInstanceCallCount = 0
#                 $script:methodRemoveInstanceCallCount = 0
#             }
#         }

#         Context 'When the resource does not exist' {
#             It 'Should call method NewInstance()' {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $mockProperties = @{
#                         Transport = 'HTTP'
#                         Ensure    = 'Present'
#                     }

#                     $script:mockInstance.Modify($mockProperties)

#                     $script:methodNewInstanceCallCount | Should -Be 1
#                     $script:methodRemoveInstanceCallCount | Should -Be 0
#                 }
#             }
#         }

#         Context 'When the resource does exist' {
#             It 'Should call method RemoveInstance()' {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $script:mockInstance.Ensure = 'Absent'

#                     $mockProperties = @{
#                         Transport = 'HTTP'
#                         Ensure    = 'Absent'
#                     }

#                     $script:mockInstance.Modify($mockProperties)

#                     $script:methodNewInstanceCallCount | Should -Be 0
#                     $script:methodRemoveInstanceCallCount | Should -Be 1
#                 }
#             }
#         }

#         Context 'When the resource does exist but properties are incorrect' {
#             It 'Should call method RemoveInstance() and NewInstance()' {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $script:mockInstance.Ensure = 'Present'

#                     $mockProperties = @{
#                         Transport = 'HTTP'
#                         Port      = 5000
#                     }

#                     $script:mockInstance.Modify($mockProperties)

#                     $script:methodRemoveInstanceCallCount | Should -Be 1
#                     $script:methodNewInstanceCallCount | Should -Be 1
#                 }
#             }
#         }
#     }
# }

# Describe 'WSManListener\NewInstance()' -Tag 'HiddenMember' {
#     BeforeAll {
#         Mock -CommandName New-WSManInstance
#     }

#     Context 'When creating a HTTP Transport' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance = [WSManListener] @{
#                     Transport = 'HTTP'
#                     Port      = 5985
#                     Address   = '*'
#                     Ensure    = 'Present'
#                 }
#             }
#         }

#         It 'Should call the correct mock' {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance.NewInstance()
#             }

#             Should -Invoke -CommandName New-WSManInstance -Exactly -Times 1 -Scope It
#         }
#     }

#     Context 'When creating a HTTPS Transport' {
#         BeforeAll {
#             Mock -CommandName Get-DscProperty
#         }

#         BeforeEach {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance = [WSManListener] @{
#                     Transport = 'HTTPS'
#                     Port      = 5986
#                     Address   = '*'
#                     Ensure    = 'Present'
#                 }
#             }
#         }

#         Context 'When the certificate thumbprint exists' {
#             BeforeAll {
#                 Mock -CommandName Find-Certificate -MockWith {
#                     @{ Thumbprint = '74FA31ADEA7FDD5333CED10910BFA6F665A1F2FC' }
#                 }
#             }

#             Context 'When the hostname is provided' {
#                 It 'Should call the correct mocks' {
#                     InModuleScope -ScriptBlock {
#                         Set-StrictMode -Version 1.0

#                         $script:mockInstance.HostName = 'somehost'

#                         $script:mockInstance.NewInstance()
#                     }

#                     Should -Invoke -CommandName Get-DscProperty -Exactly -Times 1 -Scope It
#                     Should -Invoke -CommandName Find-Certificate -Exactly -Times 1 -Scope It
#                     Should -Invoke -CommandName New-WSManInstance -ParameterFilter {
#                         $ValueSet.HostName -eq 'somehost'
#                     } -Exactly -Times 1 -Scope It
#                 }
#             }

#             Context 'When the hostname is not provided' {
#                 It 'Should call the correct mock' {
#                     InModuleScope -ScriptBlock {
#                         Set-StrictMode -Version 1.0

#                         $script:mockInstance.NewInstance()
#                     }

#                     Should -Invoke -CommandName Get-DscProperty -Exactly -Times 1 -Scope It
#                     Should -Invoke -CommandName Find-Certificate -Exactly -Times 1 -Scope It
#                     Should -Invoke -CommandName New-WSManInstance -ParameterFilter {
#                         $ValueSet.HostName -eq [System.Net.Dns]::GetHostEntry((Get-ComputerName)).Hostname
#                     } -Exactly -Times 1 -Scope It
#                 }
#             }
#         }

#         Context 'When the certificate thumbprint does not exist' {
#             BeforeAll {
#                 Mock -CommandName Find-Certificate
#             }

#             It 'Should throw the correct exception' {
#                 InModuleScope -ScriptBlock {
#                     Set-StrictMode -Version 1.0

#                     $mockErrorMessage = Get-InvalidArgumentRecord -Message (
#                         $script:mockInstance.localizedData.ListenerCreateFailNoCertError -f $script:mockInstance.Transport, $script:mockInstance.Port
#                     ) -Argument 'Issuer'

#                     { $script:mockInstance.NewInstance() } | Should -Throw -ExpectedMessage $mockErrorMessage.Exception.Message
#                 }

#                 Should -Invoke -CommandName New-WSManInstance -Exactly -Times 0 -Scope It
#                 Should -Invoke -CommandName Get-DscProperty -Exactly -Times 1 -Scope It
#                 Should -Invoke -CommandName Find-Certificate -Exactly -Times 1 -Scope It
#             }
#         }
#     }

#     Context 'When the parameters ''Port'' and ''Address'' is not set' {
#         BeforeAll {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance = [WSManListener] @{
#                     Transport = 'HTTP'
#                     Ensure    = 'Present'
#                 }
#             }

#             Mock -CommandName Get-DefaultPort -MockWith {
#                 return [System.UInt16] 5985
#             }
#         }

#         It 'Should create the listener correctly' {
#             InModuleScope -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 $script:mockInstance.NewInstance()
#             }

#             Should -Invoke -CommandName New-WSManInstance -Exactly -Times 1 -Scope It
#             Should -Invoke -CommandName Get-DefaultPort -Exactly -Times 1 -Scope It
#         }
#     }
# }

# Describe 'WSManListener\RemoveInstance()' -Tag 'HiddenMember' {
#     BeforeAll {
#         InModuleScope -ScriptBlock {
#             Set-StrictMode -Version 1.0

#             $script:mockInstance = [WSManListener] @{
#                 Transport = 'HTTPS'
#                 Port      = 5986
#                 Address   = '*'
#                 Ensure    = 'Present'
#             }
#         }

#         Mock -CommandName Remove-WSManInstance
#     }

#     It 'Should call the correct mock' {
#         InModuleScope -ScriptBlock {
#             Set-StrictMode -Version 1.0

#             $script:mockInstance.RemoveInstance()
#         }

#         Should -Invoke -CommandName Remove-WSManInstance -Exactly -Times 1 -Scope It
#     }
# }

# Describe 'WSManListener\AssertProperties()' -Tag 'AssertProperties' {
#     BeforeAll {
#         InModuleScope -ScriptBlock {
#             Set-StrictMode -Version 1.0

#             $script:mockInstance = [WSManListener] @{}
#         }
#     }

#     Context 'When passing mutually exclusive parameters' {
#         BeforeDiscovery {
#             $testCases = @(
#                 @{
#                     Issuer   = 'SomeIssuer'
#                     HostName = 'TheHostname'
#                 }
#                 @{
#                     Issuer                = 'SomeIssuer'
#                     CertificateThumbprint = 'certificateThumbprint'
#                 }
#                 @{
#                     BaseDN   = 'SomeBaseDN'
#                     HostName = 'TheHostname'
#                 }
#                 @{
#                     BaseDN                = 'SomeBaseDN'
#                     CertificateThumbprint = 'certificateThumbprint'
#                 }
#                 @{
#                     SubjectFormat = 1
#                     HostName      = 'TheHostname'
#                 }
#                 @{
#                     SubjectFormat         = 1
#                     CertificateThumbprint = 'certificateThumbprint'
#                 }
#                 @{
#                     MatchAlternate = 'MatchAlternate'
#                     HostName       = 'TheHostname'
#                 }
#                 @{
#                     MatchAlternate        = 'MatchAlternate'
#                     CertificateThumbprint = 'certificateThumbprint'
#                 }
#             )
#         }

#         It 'Should throw the correct error' -ForEach $testCases {
#             InModuleScope -Parameters @{
#                 mockProperties = $_
#             } -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 if ($mockProperties.SubjectFormat)
#                 {
#                     $mockProperties.SubjectFormat = [WSManSubjectFormat]$mockProperties.SubjectFormat
#                 }

#                 { $mockInstance.AssertProperties($mockProperties) } | Should -Throw -ExpectedMessage ('*' + 'DRC0010' + '*')
#             }
#         }
#     }

#     Context 'When passing mutually inclusive parameters' {
#         BeforeDiscovery {
#             $testCases = @(
#                 @{
#                     Issuer         = 'SomeIssuer'
#                     BaseDN         = 'SomeBaseDN'
#                     SubjectFormat  = 0
#                     MatchAlternate = 'MatchAlternate'
#                 }
#                 @{

#                     HostName              = 'TheHostname'
#                     CertificateThumbprint = 'certificateThumbprint'
#                 }
#             )
#         }

#         It 'Should not throw an error' -ForEach $testCases {
#             InModuleScope -Parameters @{
#                 mockProperties = $_
#             } -ScriptBlock {
#                 Set-StrictMode -Version 1.0

#                 if ($mockProperties.SubjectFormat)
#                 {
#                     $mockProperties.SubjectFormat = [WSManSubjectFormat]$mockProperties.SubjectFormat
#                 }

#                 { $mockInstance.AssertProperties($mockProperties) } | Should -Not -Throw
#             }
#         }
#     }
# }
