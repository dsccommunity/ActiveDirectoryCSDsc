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

    # Load stub cmdlets and classes.
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\Stubs\AdcsAdministrationStub.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload stub module
    Remove-Module -Name AdcsAdministrationStub -Force

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Get-CaAiaUriList' -Tag 'Private' {
    Context 'When ExtensionType is AddToCertificateAia and there are only AddToCertificateOcsp URIs' {
        BeforeAll {
            Mock -CommandName Get-CAAuthorityInformationAccess -MockWith {
                return @(
                    [PSCustomObject] @{
                        AddToCertificateAia  = $false
                        AddToCertificateOcsp = $true
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    }
                )
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:result = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia' } | Should -Not -Throw

                $result | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-CAAuthorityInformationAccess -Exactly -Times 1 -Scope It
        }
    }

    Context 'When ExtensionType is AddToCertificateAia and there is one AddToCertificateAia URI and one AddToCertificateOcsp URI' {
        BeforeAll {
            Mock -CommandName Get-CAAuthorityInformationAccess -MockWith {
                return @(
                    [PSCustomObject] @{
                        AddToCertificateAia  = $false
                        AddToCertificateOcsp = $true
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    },
                    [PSCustomObject] @{
                        AddToCertificateAia  = $true
                        AddToCertificateOcsp = $false
                        Uri                  = 'http://primary/Certs/<CATruncatedName>.cer'
                    }
                )
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:result = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia' } | Should -Not -Throw
                $result | Should -BeExactly 'http://primary/Certs/<CATruncatedName>.cer'
            }

            Should -Invoke -CommandName Get-CAAuthorityInformationAccess -Exactly -Times 1 -Scope It
        }
    }

    Context 'When ExtensionType is AddToCertificateAia and there is two AddToCertificateAia URI and one AddToCertificateOcsp URIs' {
        BeforeAll {
            $getCAAuthorityInformationAccessMock = {
                @(
                    [PSCustomObject] @{
                        AddToCertificateAia  = $false
                        AddToCertificateOcsp = $true
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    },
                    [PSCustomObject] @{
                        AddToCertificateAia  = $true
                        AddToCertificateOcsp = $false
                        Uri                  = 'http://primary/Certs/<CATruncatedName>.cer'
                    },
                    [PSCustomObject] @{
                        AddToCertificateAia  = $true
                        AddToCertificateOcsp = $false
                        Uri                  = 'http://secondary/Certs/<CATruncatedName>.cer'
                    }
                )
            }

            Mock -CommandName Get-CAAuthorityInformationAccess -MockWith $getCAAuthorityInformationAccessMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia'
                } | Should -Not -Throw
            }
        }

        It 'Should return two entries' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getCaAiaUriListResult[0] | Should -BeExactly 'http://primary/Certs/<CATruncatedName>.cer'
                $getCaAiaUriListResult[1] | Should -BeExactly 'http://secondary/Certs/<CATruncatedName>.cer'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-CAAuthorityInformationAccess `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When ExtensionType is AddToCertificateAia and there are only AddToCertificateAia URIs' {
        BeforeAll {
            $getCAAuthorityInformationAccessMock = {
                @(
                    [PSCustomObject] @{
                        AddToCertificateAia  = $true
                        AddToCertificateOcsp = $false
                        Uri                  = 'http://primary/Certs/<CATruncatedName>.cer'
                    }
                )
            }

            Mock -CommandName Get-CAAuthorityInformationAccess -MockWith $getCAAuthorityInformationAccessMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp'
                } | Should -Not -Throw
            }
        }

        It 'Should return null' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getCaAiaUriListResult | Should -BeNullOrEmpty
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke -CommandName Get-CAAuthorityInformationAccess -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When ExtensionType is AddToCertificateOcsp and there is AddToCertificateOcsp URI and one AddToCertificateAia URI' {
        BeforeAll {
            $getCAAuthorityInformationAccessMock = {
                @(
                    [PSCustomObject] @{
                        AddToCertificateAia  = $false
                        AddToCertificateOcsp = $true
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    },
                    [PSCustomObject] @{
                        AddToCertificateAia  = $true
                        AddToCertificateOcsp = $false
                        Uri                  = 'http://primary/Certs/<CATruncatedName>.cer'
                    }
                )
            }

            Mock -CommandName Get-CAAuthorityInformationAccess -MockWith $getCAAuthorityInformationAccessMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp'
                } | Should -Not -Throw
            }
        }

        It 'Should return one OCSP entry' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getCaAiaUriListResult | Should -BeExactly 'http://primary-ocsp-responder/ocsp'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke -CommandName Get-CAAuthorityInformationAccess -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When ExtensionType is AddToCertificateOcsp and there is AddToCertificateOcsp URI and two AddToCertificateAia URIs' {
        BeforeAll {
            $getCAAuthorityInformationAccessMock = {
                @(
                    [PSCustomObject] @{
                        AddToCertificateAia  = $false
                        AddToCertificateOcsp = $true
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    },
                    [PSCustomObject] @{
                        AddToCertificateAia  = $false
                        AddToCertificateOcsp = $true
                        Uri                  = 'http://secondary-ocsp-responder/ocsp'
                    },
                    [PSCustomObject] @{
                        AddToCertificateAia  = $true
                        AddToCertificateOcsp = $false
                        Uri                  = 'http://primary/Certs/<CATruncatedName>.cer'
                    }
                )
            }

            Mock -CommandName Get-CAAuthorityInformationAccess -MockWith $getCAAuthorityInformationAccessMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp'
                } | Should -Not -Throw
            }
        }

        It 'Should return the correct URIs' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getCaAiaUriListResult[0] | Should -BeExactly 'http://primary-ocsp-responder/ocsp'
                $getCaAiaUriListResult[1] | Should -BeExactly 'http://secondary-ocsp-responder/ocsp'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke -CommandName Get-CAAuthorityInformationAccess -Exactly -Times 1 -Scope Context
        }
    }
}
