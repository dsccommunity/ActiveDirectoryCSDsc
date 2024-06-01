<#
    .SYNOPSIS
        Unit test for DSC_AdcsAuthorityInformationAccess DSC resource.

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
    $script:dscResourceName = 'DSC_AdcsAuthorityInformationAccess'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\Stubs\AdcsAdministrationStub.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\Stubs\AdcsDeploymentStub.psm1')


    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName

    $script:AiaList = [System.String[]] @(
        'http://primary/Certs/<CATruncatedName>.cer'
        'http://secondary/Certs/<CATruncatedName>.cer'
    )
    $script:OcspList = [System.String[]] @(
        'http://primary-ocsp-responder/ocsp'
        'http://secondary-ocsp-responder/ocsp'
    )

    InModuleScope -Parameters @{
        AiaList  = $AiaList
        OcspList = $OcspList
    } -ScriptBlock {
        $script:AiaList = $AiaList
        $script:OcspList = $OcspList
    }

    $script:getCaAiaUriListAiaMock = {
        $AiaList
    }
    $script:getCaAiaUriListAiaParameterFilter = {
        $ExtensionType -eq 'AddToCertificateAia'
    }
    $script:getCaAiaUriListOcspMock = {
        $OcspList
    }
    $script:getCaAiaUriListOcspParameterFilter = {
        $ExtensionType -eq 'AddToCertificateOcsp'
    }

    $script:getTargetResourceMock = {
        @{
            IsSingleInstance    = 'Yes'
            AiaUri              = $AiaList
            OcspUri             = $OcspList
            AllowRestartService = $false
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

    Remove-Module -Name AdcsAdministrationStub -Force
    Remove-Module -Name AdcsDeploymentStub -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe 'DSC_AdcsAuthorityInformationAccess\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            $script:getTargetResourceParameters = @{
                IsSingleInstance = 'Yes'
            }
        }
    }

    Context 'When there are no AIA or OCSP URIs set' {
        BeforeAll {
            Mock -CommandName Get-CaAiaUriList `
                -MockWith { @() } `
                -ParameterFilter $getCaAiaUriListOcspParameterFilter

            Mock -CommandName Get-CaAiaUriList `
                -MockWith { @() } `
                -ParameterFilter $getCaAiaUriListAiaParameterFilter
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return expected hash table' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult.IsSingleInstance | Should -BeExactly 'Yes'
                $getTargetResourceResult.AiaUri | Should -BeNullOrEmpty
                $getTargetResourceResult.OcspUri | Should -BeNullOrEmpty
                $getTargetResourceResult.AllowRestartService | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-CaAiaUriList  `
                -Exactly -Times 2 -Scope Context
        }
    }

    Context 'When there are AIA and OCSP URIs set' {
        BeforeAll {
            Mock -CommandName Get-CaAiaUriList `
                -MockWith $getCaAiaUriListOcspMock `
                -ParameterFilter $getCaAiaUriListOcspParameterFilter

            Mock -CommandName Get-CaAiaUriList `
                -MockWith $getCaAiaUriListAiaMock `
                -ParameterFilter $getCaAiaUriListAiaParameterFilter
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                {
                    $script:getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return expected hash table' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult.IsSingleInstance | Should -BeExactly 'Yes'
                $getTargetResourceResult.AiaUri | Should -BeExactly $AiaList
                $getTargetResourceResult.OcspUri | Should -BeExactly $OcspList
                $getTargetResourceResult.AllowRestartService | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-CaAiaUriList  `
                -Exactly -Times 2 -Scope Context
        }
    }
}

Describe 'DSC_AdcsAuthorityInformationAccess\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Add-CAAuthorityInformationAccess

        Mock -CommandName Remove-CAAuthorityInformationAccess

        Mock -CommandName Restart-ServiceIfExists
    }

    Context 'When AllowRestartService is true' {
        Context 'When AIA and OCSP are passed but are both in the correct state' {
            BeforeAll {
                InModuleScope -ScriptBlock {

                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $AiaList
                        OcspUri             = $OcspList
                        AllowRestartService = $true
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }

        Context 'When AIA and OCSP are passed but AIA is missing a URI' {
            BeforeAll {
                InModuleScope -ScriptBlock {

                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $AiaList + ('http://tertiary/Certs/<CATruncatedName>.cer')
                        OcspUri             = $OcspList
                        AllowRestartService = $true
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://tertiary/Certs/<CATruncatedName>.cer' -and `
                        $AddToCertificateAia -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -ParameterFilter {
                    $Name -eq 'CertSvc'
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }

        Context 'When AIA and OCSP are passed but OCSP is missing a URI' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $AiaList
                        OcspUri             = $OcspList + @('http://tertiary-ocsp-responder/ocsp')
                        AllowRestartService = $true
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://tertiary-ocsp-responder/ocsp' -and `
                        $AddToCertificateOcsp -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -ParameterFilter {
                    $Name -eq 'CertSvc'
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }

        Context 'When AIA and OCSP are passed but AIA has an extra URI' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = [System.String[]] @('http://primary/Certs/<CATruncatedName>.cer')
                        OcspUri             = $OcspList
                        AllowRestartService = $true
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://secondary/Certs/<CATruncatedName>.cer' -and `
                        $AddToCertificateAia -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -ParameterFilter {
                    $Name -eq 'CertSvc'
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }

        Context 'When AIA and OCSP are passed but OCSP has an extra URI' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $AiaList
                        OcspUri             = [System.String[]] @('http://primary-ocsp-responder/ocsp')
                        AllowRestartService = $true
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0
                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://secondary-ocsp-responder/ocsp' -and `
                        $AddToCertificateOcsp -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -ParameterFilter {
                    $Name -eq 'CertSvc'
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }

        Context 'When only AIA is passed but has different values' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = [System.String[]] @(
                            'http://secondary/Certs/<CATruncatedName>.cer'
                            'http://tertiary/Certs/<CATruncatedName>.cer'
                        )
                        AllowRestartService = $true
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://tertiary/Certs/<CATruncatedName>.cer' -and `
                        $AddToCertificateAia -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://primary/Certs/<CATruncatedName>.cer' -and `
                        $AddToCertificateAia -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -ParameterFilter {
                    $Name -eq 'CertSvc'
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }

        Context 'When only OCSP is passed but has different values' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        OcspUri             = [System.String[]] @(
                            'http://secondary-ocsp-responder/ocsp'
                            'http://tertiary-ocsp-responder/ocsp'
                        )
                        AllowRestartService = $true
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0
                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://tertiary-ocsp-responder/ocsp' -and `
                        $AddToCertificateOcsp -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://primary-ocsp-responder/ocsp' -and `
                        $AddToCertificateOcsp -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -ParameterFilter {
                    $Name -eq 'CertSvc'
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }
    }

    Context 'When AllowRestartService is false' {
        Context 'When only AIA is passed but has different values' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = [System.String[]] @(
                            'http://secondary/Certs/<CATruncatedName>.cer'
                            'http://tertiary/Certs/<CATruncatedName>.cer'
                        )
                        AllowRestartService = $false
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://tertiary/Certs/<CATruncatedName>.cer' -and `
                        $AddToCertificateAia -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://primary/Certs/<CATruncatedName>.cer' -and `
                        $AddToCertificateAia -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }

        Context 'When only OCSP is passed but has different values' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    $script:setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        OcspUri             = [System.String[]] @(
                            'http://secondary-ocsp-responder/ocsp'
                            'http://tertiary-ocsp-responder/ocsp'
                        )
                        AllowRestartService = $false
                    }
                }

                Mock -CommandName Get-TargetResource `
                    -MockWith $getTargetResourceMock
            }

            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    {
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Add-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://tertiary-ocsp-responder/ocsp' -and `
                        $AddToCertificateOcsp -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Remove-CAAuthorityInformationAccess `
                    -ParameterFilter {
                    $Uri -eq 'http://primary-ocsp-responder/ocsp' -and `
                        $AddToCertificateOcsp -eq $true
                } `
                    -Exactly -Times 1 -Scope Context

                Should -Invoke `
                    -CommandName Restart-ServiceIfExists `
                    -Exactly -Times 0 -Scope Context

                Should -Invoke `
                    -CommandName Get-TargetResource `
                    -Exactly -Times 1 -Scope Context
            }
        }
    }
}

Describe 'DSC_AdcsAuthorityInformationAccess\Test-TargetResource' -Tag 'Test' {
    Context 'When AIA and OCSP are passed and in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $script:testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $AiaList
                    OcspUri             = $OcspList
                    AllowRestartService = $false
                }
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeTrue
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When AIA and OCSP are passed and OCSP contains an extra value' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $script:testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $AiaList
                    OcspUri             = $OcspList + @('http://tertiary-ocsp-responder/ocsp')
                    AllowRestartService = $false
                }
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When AIA and OCSP are passed and AIA contains an extra value' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $script:testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $AiaList + ('http://tertiary/Certs/<CATruncatedName>.cer')
                    OcspUri             = $OcspList
                    AllowRestartService = $false
                }
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When AIA and OCSP are passed and both AIA and OCSP contains extra values' {
        BeforeAll {
            $script:testTargetResourceParameters = @{
                IsSingleInstance    = 'Yes'
                AiaUri              = $AiaList + ('http://tertiary/Certs/<CATruncatedName>.cer')
                OcspUri             = $OcspList + @('http://tertiary-ocsp-responder/ocsp')
                AllowRestartService = $false
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When AIA and OCSP are passed and OCSP is empty' {
        BeforeAll {
            $testTargetResourceParameters = @{
                IsSingleInstance    = 'Yes'
                AiaUri              = $AiaList
                OcspUri             = [System.String[]] @()
                AllowRestartService = $false
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeFalse
            }
        }
    }

    Context 'When AIA and OCSP are passed and AIA is empty' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $script:testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = [System.String[]] @()
                    OcspUri             = $OcspList
                    AllowRestartService = $false
                }
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When AIA and OCSP are passed and both AIA and OCSP are empty' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $script:testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = [System.String[]] @()
                    OcspUri             = [System.String[]] @()
                    AllowRestartService = $false
                }
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When only AIA is passed and is in desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $script:testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $AiaList
                    AllowRestartService = $false
                }
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeTrue
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When only OCSP is passed and is in desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $script:testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    OcspUri             = $OcspList
                    AllowRestartService = $false
                }
            }

            Mock -CommandName Get-TargetResource `
                -MockWith $getTargetResourceMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeTrue
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-TargetResource `
                -Exactly -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsAuthorityInformationAccess\Get-CaAiaUriList' {
    Context 'When ExtensionType is AddToCertificateAia and there are only AddToCertificateOcsp URIs' {
        BeforeAll {
            $getCAAuthorityInformationAccessMock = {
                @(
                    [PSCustomObject] @{
                        AddToCertificateAia  = $false
                        AddToCertificateOcsp = $true
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    }
                )
            }

            Mock `
                -CommandName Get-CAAuthorityInformationAccess `
                -MockWith $getCAAuthorityInformationAccessMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia'
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
            Should -Invoke `
                -CommandName Get-CAAuthorityInformationAccess `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When ExtensionType is AddToCertificateAia and there is AddToCertificateAia URI and one AddToCertificateOcsp URI' {
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

            Mock `
                -CommandName Get-CAAuthorityInformationAccess `
                -MockWith $getCAAuthorityInformationAccessMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia'
                } | Should -Not -Throw
            }
        }

        It 'Should return null' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getCaAiaUriListResult | Should -BeExactly 'http://primary/Certs/<CATruncatedName>.cer'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-CAAuthorityInformationAccess `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When ExtensionType is AddToCertificateAia and there is AddToCertificateAia URI and two AddToCertificateOcsp URIs' {
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

            Mock `
                -CommandName Get-CAAuthorityInformationAccess `
                -MockWith $getCAAuthorityInformationAccessMock
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia'
                } | Should -Not -Throw
            }
        }

        It 'Should return null' {
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

    Context 'When ExtensionType is AddToCertificateOcsp and there are only AddToCertificateAia URIs' {
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

            Mock `
                -CommandName Get-CAAuthorityInformationAccess `
                -MockWith $getCAAuthorityInformationAccessMock
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
            Should -Invoke `
                -CommandName Get-CAAuthorityInformationAccess `
                -Exactly -Times 1 -Scope Context
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

            Mock `
                -CommandName Get-CAAuthorityInformationAccess `
                -MockWith $getCAAuthorityInformationAccessMock
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

                $getCaAiaUriListResult | Should -BeExactly 'http://primary-ocsp-responder/ocsp'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Get-CAAuthorityInformationAccess `
                -Exactly -Times 1 -Scope Context
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

            Mock `
                -CommandName Get-CAAuthorityInformationAccess `
                -MockWith $getCAAuthorityInformationAccessMock
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
            Should -Invoke `
                -CommandName Get-CAAuthorityInformationAccess `
                -Exactly -Times 1 -Scope Context
        }
    }
}
