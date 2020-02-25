$script:dscModuleName = 'ActiveDirectoryCSDsc'
$script:dscResourceName = 'DSC_AdcsAuthorityInformationAccess'

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
        $script:AiaList = [System.String[]] @(
            'http://primary/Certs/<CATruncatedName>.cer'
            'http://secondary/Certs/<CATruncatedName>.cer'
        )
        $script:getCaAiaUriListAiaMock = {
            $script:AiaList
        }
        $script:getCaAiaUriListAiaParameterFilter = {
            $ExtensionType -eq 'AddToCertificateAia'
        }
        $script:OcspList = [System.String[]] @(
            'http://primary-ocsp-responder/ocsp'
            'http://secondary-ocsp-responder/ocsp'
        )
        $script:getCaAiaUriListOcspMock = {
            $script:OcspList
        }
        $script:getCaAiaUriListOcspParameterFilter = {
            $ExtensionType -eq 'AddToCertificateOcsp'
        }
        $script:getTargetResourceMock = {
            @{
                IsSingleInstance    = 'Yes'
                AiaUri              = $script:AiaList
                OcspUri             = $script:OcspList
                AllowRestartService = $false
            }
        }

        Describe 'DSC_AdcsAuthorityInformationAccess\Get-TargetResource' -Tag 'Get' {
            $script:getTargetResourceParameters = @{
                IsSingleInstance = 'Yes'
                Verbose          = $true
            }

            Context 'When there are no AIA or OCSP URIs set' {
                Mock -CommandName Get-CaAiaUriList `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith { @() } `
                    -ParameterFilter $script:getCaAiaUriListOcspParameterFilter

                Mock -CommandName Get-CaAiaUriList `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith { @() } `
                    -ParameterFilter $script:getCaAiaUriListAiaParameterFilter

                It 'Should not throw an exception' {
                    {
                        $script:getTargetResourceResult = Get-TargetResource @script:getTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return expected hash table' {
                    $script:getTargetResourceResult.IsSingleInstance | Should -BeExactly 'Yes'
                    $script:getTargetResourceResult.AiaUri | Should -BeNullOrEmpty
                    $script:getTargetResourceResult.OcspUri | Should -BeNullOrEmpty
                    $script:getTargetResourceResult.AllowRestartService | Should -BeFalse
                }
            }

            Context 'When there are AIA and OCSP URIs set' {
                Mock -CommandName Get-CaAiaUriList `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getCaAiaUriListOcspMock `
                    -ParameterFilter $script:getCaAiaUriListOcspParameterFilter

                Mock -CommandName Get-CaAiaUriList `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getCaAiaUriListAiaMock `
                    -ParameterFilter $script:getCaAiaUriListAiaParameterFilter

                It 'Should not throw an exception' {
                    {
                        $script:getTargetResourceResult = Get-TargetResource @script:getTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return expected hash table' {
                    $script:getTargetResourceResult.IsSingleInstance | Should -BeExactly 'Yes'
                    $script:getTargetResourceResult.AiaUri | Should -BeExactly $script:AiaList
                    $script:getTargetResourceResult.OcspUri | Should -BeExactly $script:OcspList
                    $script:getTargetResourceResult.AllowRestartService | Should -BeFalse
                }
            }
        }

        Describe 'DSC_AdcsAuthorityInformationAccess\Set-TargetResource' -Tag 'Set' {
            BeforeAll {
                Mock -CommandName Add-CAAuthorityInformationAccess `
                    -ModuleName DSC_AdcsAuthorityInformationAccess

                Mock -CommandName Remove-CAAuthorityInformationAccess `
                    -ModuleName DSC_AdcsAuthorityInformationAccess

                Mock -CommandName Restart-ServiceIfExists `
                    -ModuleName DSC_AdcsAuthorityInformationAccess
            }

            Context 'When AllowRestartService is true' {
                Context 'When AIA and OCSP are passed but are both in the correct state' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $script:AiaList
                        OcspUri             = $script:OcspList
                        AllowRestartService = $true
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -Exactly -Times 0

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -Exactly -Times 0

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -Exactly -Times 0
                    }
                }

                Context 'When AIA and OCSP are passed but OCSP is missing a URI' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $script:AiaList + ('http://tertiary/Certs/<CATruncatedName>.cer')
                        OcspUri             = $script:OcspList
                        AllowRestartService = $true
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://tertiary/Certs/<CATruncatedName>.cer' -and `
                                $AddToCertificateAia -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -Exactly -Times 0

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -ParameterFilter {
                            $Name -eq 'CertSvc'
                        } `
                            -Exactly -Times 1
                    }
                }

                Context 'When AIA and OCSP are passed but AIA is missing a URI' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $script:AiaList
                        OcspUri             = $script:OcspList + @('http://tertiary-ocsp-responder/ocsp')
                        AllowRestartService = $true
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://tertiary-ocsp-responder/ocsp' -and `
                                $AddToCertificateOcsp -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -Exactly -Times 0

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -ParameterFilter {
                            $Name -eq 'CertSvc'
                        } `
                            -Exactly -Times 1
                    }
                }

                Context 'When AIA and OCSP are passed but OCSP has an extra URI' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = [System.String[]] @('http://primary/Certs/<CATruncatedName>.cer')
                        OcspUri             = $script:OcspList
                        AllowRestartService = $true
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -Exactly -Times 0

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://secondary/Certs/<CATruncatedName>.cer' -and `
                                $AddToCertificateAia -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -ParameterFilter {
                            $Name -eq 'CertSvc'
                        } `
                            -Exactly -Times 1
                    }
                }

                Context 'When AIA and OCSP are passed but AIA has an extra URI' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = $script:AiaList
                        OcspUri             = [System.String[]] @('http://primary-ocsp-responder/ocsp')
                        AllowRestartService = $true
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -Exactly -Times 0

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://secondary-ocsp-responder/ocsp' -and `
                                $AddToCertificateOcsp -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -ParameterFilter {
                            $Name -eq 'CertSvc'
                        } `
                            -Exactly -Times 1
                    }
                }

                Context 'When only AIA is passed but has different values' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = [System.String[]] @(
                            'http://secondary/Certs/<CATruncatedName>.cer'
                            'http://tertiary/Certs/<CATruncatedName>.cer'
                        )
                        AllowRestartService = $true
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://tertiary/Certs/<CATruncatedName>.cer' -and `
                                $AddToCertificateAia -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://primary/Certs/<CATruncatedName>.cer' -and `
                                $AddToCertificateAia -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -ParameterFilter {
                            $Name -eq 'CertSvc'
                        } `
                            -Exactly -Times 1
                    }
                }

                Context 'When only OCSP is passed but has different values' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        OcspUri             = [System.String[]] @(
                            'http://secondary-ocsp-responder/ocsp'
                            'http://tertiary-ocsp-responder/ocsp'
                        )
                        AllowRestartService = $true
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://tertiary-ocsp-responder/ocsp' -and `
                                $AddToCertificateOcsp -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://primary-ocsp-responder/ocsp' -and `
                                $AddToCertificateOcsp -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -ParameterFilter {
                            $Name -eq 'CertSvc'
                        } `
                            -Exactly -Times 1
                    }
                }
            }

            Context 'When AllowRestartService is false' {
                Context 'When only AIA is passed but has different values' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        AiaUri              = [System.String[]] @(
                            'http://secondary/Certs/<CATruncatedName>.cer'
                            'http://tertiary/Certs/<CATruncatedName>.cer'
                        )
                        AllowRestartService = $false
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://tertiary/Certs/<CATruncatedName>.cer' -and `
                                $AddToCertificateAia -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://primary/Certs/<CATruncatedName>.cer' -and `
                                $AddToCertificateAia -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -Exactly -Times 0
                    }
                }

                Context 'When only OCSP is passed but has different values' {
                    $setTargetResourceParameters = @{
                        IsSingleInstance    = 'Yes'
                        OcspUri             = [System.String[]] @(
                            'http://secondary-ocsp-responder/ocsp'
                            'http://tertiary-ocsp-responder/ocsp'
                        )
                        AllowRestartService = $false
                        Verbose             = $true
                    }

                    Mock -CommandName Get-TargetResource `
                        -ModuleName DSC_AdcsAuthorityInformationAccess `
                        -MockWith $script:getTargetResourceMock

                    It 'Should not throw an exception' {
                        {
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should call expected mocks' {
                        Assert-MockCalled `
                            -CommandName Add-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://tertiary-ocsp-responder/ocsp' -and `
                                $AddToCertificateOcsp -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Remove-CAAuthorityInformationAccess `
                            -ParameterFilter {
                            $Uri -eq 'http://primary-ocsp-responder/ocsp' -and `
                                $AddToCertificateOcsp -eq $true
                        } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -Exactly -Times 0
                    }
                }
            }
        }

        Describe 'DSC_AdcsAuthorityInformationAccess\Test-TargetResource' -Tag 'Test' {
            Context 'When AIA and OCSP are passed and in the desired state' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $script:AiaList
                    OcspUri             = $script:OcspList
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return true' {
                    $script:testTargetResourceResult | Should -BeTrue
                }
            }

            Context 'When AIA and OCSP are passed and OCSP contains an extra value' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $script:AiaList
                    OcspUri             = $script:OcspList + @('http://tertiary-ocsp-responder/ocsp')
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return false' {
                    $script:testTargetResourceResult | Should -BeFalse
                }
            }

            Context 'When AIA and OCSP are passed and AIA contains an extra value' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $script:AiaList + ('http://tertiary/Certs/<CATruncatedName>.cer')
                    OcspUri             = $script:OcspList
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return false' {
                    $script:testTargetResourceResult | Should -BeFalse
                }
            }

            Context 'When AIA and OCSP are passed and both AIA and OCSP contains extra values' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $script:AiaList + ('http://tertiary/Certs/<CATruncatedName>.cer')
                    OcspUri             = $script:OcspList + @('http://tertiary-ocsp-responder/ocsp')
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return false' {
                    $script:testTargetResourceResult | Should -BeFalse
                }
            }

            Context 'When AIA and OCSP are passed and OCSP is empty' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $script:AiaList
                    OcspUri             = [System.String[]] @()
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return false' {
                    $script:testTargetResourceResult | Should -BeFalse
                }
            }

            Context 'When AIA and OCSP are passed and AIA is empty' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = [System.String[]] @()
                    OcspUri             = $script:OcspList
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return false' {
                    $script:testTargetResourceResult | Should -BeFalse
                }
            }

            Context 'When AIA and OCSP are passed and both AIA and OCSP are empty' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = [System.String[]] @()
                    OcspUri             = [System.String[]] @()
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return false' {
                    $script:testTargetResourceResult | Should -BeFalse
                }
            }

            Context 'When only AIA is passed and is in desired state' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    AiaUri              = $script:AiaList
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return true' {
                    $script:testTargetResourceResult | Should -BeTrue
                }
            }

            Context 'When only OCSP is passed and is in desired state' {
                $testTargetResourceParameters = @{
                    IsSingleInstance    = 'Yes'
                    OcspUri             = $script:OcspList
                    AllowRestartService = $false
                    Verbose             = $true
                }

                Mock -CommandName Get-TargetResource `
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $script:getTargetResourceMock

                It 'Should not throw an exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return true' {
                    $script:testTargetResourceResult | Should -BeTrue
                }
            }
        }

        Describe 'DSC_AdcsAuthorityInformationAccess\Get-CaAiaUriList' {
            Context 'When ExtensionType is AddToCertificateAia and there are only AddToCertificateOcsp URIs' {
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
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $getCAAuthorityInformationAccessMock

                It 'Should not throw an exception' {
                    {
                        $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia' -Verbose
                    } | Should -Not -Throw
                }

                It 'Should return null' {
                    $script:getCaAiaUriListResult | Should -BeNullOrEmpty
                }
            }

            Context 'When ExtensionType is AddToCertificateAia and there is AddToCertificateAia URI and one AddToCertificateOcsp URI' {
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
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $getCAAuthorityInformationAccessMock

                It 'Should not throw an exception' {
                    {
                        $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia' -Verbose
                    } | Should -Not -Throw
                }

                It 'Should return null' {
                    $script:getCaAiaUriListResult | Should -BeExactly 'http://primary/Certs/<CATruncatedName>.cer'
                }
            }

            Context 'When ExtensionType is AddToCertificateAia and there is AddToCertificateAia URI and two AddToCertificateOcsp URIs' {
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
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $getCAAuthorityInformationAccessMock

                It 'Should not throw an exception' {
                    {
                        $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia' -Verbose
                    } | Should -Not -Throw
                }

                It 'Should return null' {
                    $script:getCaAiaUriListResult[0] | Should -BeExactly 'http://primary/Certs/<CATruncatedName>.cer'
                    $script:getCaAiaUriListResult[1] | Should -BeExactly 'http://secondary/Certs/<CATruncatedName>.cer'
                }
            }

            Context 'When ExtensionType is AddToCertificateOcsp and there are only AddToCertificateAia URIs' {
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
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $getCAAuthorityInformationAccessMock

                It 'Should not throw an exception' {
                    {
                        $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp' -Verbose
                    } | Should -Not -Throw
                }

                It 'Should return null' {
                    $script:getCaAiaUriListResult | Should -BeNullOrEmpty
                }
            }

            Context 'When ExtensionType is AddToCertificateOcsp and there is AddToCertificateOcsp URI and one AddToCertificateAia URI' {
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
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $getCAAuthorityInformationAccessMock

                It 'Should not throw an exception' {
                    {
                        $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp' -Verbose
                    } | Should -Not -Throw
                }

                It 'Should return null' {
                    $script:getCaAiaUriListResult | Should -BeExactly 'http://primary-ocsp-responder/ocsp'
                }
            }

            Context 'When ExtensionType is AddToCertificateOcsp and there is AddToCertificateOcsp URI and two AddToCertificateAia URIs' {
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
                    -ModuleName DSC_AdcsAuthorityInformationAccess `
                    -MockWith $getCAAuthorityInformationAccessMock

                It 'Should not throw an exception' {
                    {
                        $script:getCaAiaUriListResult = Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp' -Verbose
                    } | Should -Not -Throw
                }

                It 'Should return null' {
                    $script:getCaAiaUriListResult[0] | Should -BeExactly 'http://primary-ocsp-responder/ocsp'
                    $script:getCaAiaUriListResult[1] | Should -BeExactly 'http://secondary-ocsp-responder/ocsp'
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
