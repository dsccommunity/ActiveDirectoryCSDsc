Set-StrictMode -Version Latest

$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsOcspExtension'

#region HEADER
# Unit Test Template Version: 1.1.0
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Import Stub function
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\TestHelpers\AdcsStub.psm1')

try
{
    InModuleScope $script:DSCResourceName {
        $ocspUriPathList = @(
            'http://primary-ocsp-responder/ocsp'
            'http://secondary-ocsp-responder/ocsp'
            'http://tertiary-ocsp-responder/ocsp'
        )

        $presentParams = @{
            OcspUriPath      = $ocspUriPathList
            Ensure           = 'Present'
            IsSingleInstance = 'Yes'
            RestartService   = $true
        }

        $setRestartServiceFalsePresentParams = @{
            OcspUriPath      = $ocspUriPathList
            Ensure           = 'Present'
            IsSingleInstance = 'Yes'
            RestartService   = $false
        }

        $absentParams = @{
            OcspUriPath      = $ocspUriPathList
            Ensure           = 'Absent'
            IsSingleInstance = 'Yes'
            RestartService   = $true
        }

        $setRestartServiceFalseAbsentParams = @{
            OcspUriPath      = $ocspUriPathList
            Ensure           = 'Absent'
            IsSingleInstance = 'Yes'
            RestartService   = $false
        }

        Describe 'MSFT_AdcsOcspExtension\Get-TargetResource' -Tag 'Get' {
            Context 'When the CA is installed and the Get-CAAuthorityInformationAccess cmdlet returns the OCSP URI path list' {
                $retreivedGetTargetValue = @{
                    AddToCertificateAia  = 'false'
                    AddToCertificateOcsp = 'true'
                    Uri                  = 'http://primary-ocsp-responder/ocsp'
                }

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -Mockwith { $retreivedGetTargetValue }

                It 'Should return a hashtable with the expected properties.' {
                    $result = Get-TargetResource @presentParams

                    $result                  | Should -Be System.Collections.Hashtable
                    $result.OcspUriPath      | Should -Be $retreivedGetTargetValue.Uri
                    $result.Ensure           | Should -Be $presentParams.Ensure
                    $result.IsSingleInstance | Should -Be $presentParams.IsSingleInstance
                    $result.RestartService   | Should -Be $presentParams.RestartService
                }
            }
        }

        Describe 'MSFT_AdcsOcspExtension\Set-TargetResource' -Tag 'Set' {
            Mock -CommandName Remove-CAAuthorityInformationAccess
            Mock -CommandName Add-CAAuthorityInformationAccess
            Mock -CommandName Restart-ServiceIfExists

            Context 'When ensure equals present, and OCSP record is missing, and $RestartService equals $true' {
                $missingOcspUriPath = @{
                    OcspUriPath      = @(
                        'http://primary-ocsp-responder/ocsp'
                        'http://secondary-ocsp-responder/ocsp'
                    )
                    Ensure           = 'Present'
                    IsSingleInstance = 'Yes'
                    RestartService   = $true
                }

                Mock -CommandName Get-TargetResource -MockWith { $missingOcspUriPath }

                It 'Should call the expected mocks' {
                    Set-TargetResource @presentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 2 -Scope It -ParameterFilter { $OcspUriPath -eq $presentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $OcspUriPath -eq $presentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 1 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }

            Context 'When ensure equals present, and OCSP record is missing, and $RestartService equals $false' {
                $missingOcspUriPathRestartServiceFalse = @{
                    OcspUriPath      = @(
                        'http://primary-ocsp-responder/ocsp'
                        'http://secondary-ocsp-responder/ocsp'
                    )
                    Ensure           = 'Present'
                    IsSingleInstance = 'Yes'
                    RestartService   = $false
                }

                Mock -CommandName Get-TargetResource -MockWith { $missingOcspUriPathRestartServiceFalse }

                It 'Should call the expected mocks' {
                    Set-TargetResource @setRestartServiceFalsePresentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 2 -Scope It -ParameterFilter { $OcspUriPath -eq $setRestartServiceFalsePresentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $OcspUriPath -eq $setRestartServiceFalsePresentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }

            Context 'When ensure equals absent, and OCSP records are present, and $RestartService equals $true' {
                Mock -CommandName Get-TargetResource -MockWith { $presentParams }

                It 'Should call the expected mocks' {
                    Set-TargetResource @absentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $OcspUriPath -eq $absentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 0 -Scope It -ParameterFilter { $OcspUriPath -eq $absentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 1 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }

            Context 'When ensure equals absent, and OCSP records are present, and $RestartService equals $false' {
                Mock -CommandName Get-TargetResource -MockWith { $setRestartServiceFalsePresentParams }

                It 'Should call the expected mocks' {
                    Set-TargetResource @setRestartServiceFalseAbsentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $OcspUriPath -eq $setRestartServiceFalseAbsentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 0 -Scope It -ParameterFilter { $OcspUriPath -eq $setRestartServiceFalseAbsentParams.OcspUriPathList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }
        }

        Describe 'MSFT_AdcsOcspExtension\Test-TargetResource' -Tag 'Test' {
            Context 'When ensure equals present and in desired state' {
                $desiredStateRecordReturned = @(
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    }
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://secondary-ocsp-responder/ocsp'
                    }
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://tertiary-ocsp-responder/ocsp'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $desiredStateRecordReturned }

                It 'Should return $true' {
                    $result = Test-TargetResource @presentParams

                    $result | Should -Be $true
                }
            }

            Context 'When ensure equals absent and in desired state' {
                $absentStateRecordReturned = @()

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $absentStateRecordReturned }

                It 'Should return $true' {
                    $result = Test-TargetResource @absentParams

                    $result | Should -Be $true
                }
            }

            Context 'When ensure equals present, but not in desired state, and no values stored in OCSP records when passing in a value for OCSP' {
                Mock -CommandName 'Get-CAAuthorityInformationAccess'

                It 'Should return $false' {
                    $result = Test-TargetResource @presentParams

                    $result | Should -Be $false
                }
            }

            Context 'When ensure equals present, but not in desired state, and different values are stored in OCSP records when passing in a value for OCSP' {
                $singleRecordReturned = @{
                    AddToCertificateAia  = 'false'
                    AddToCertificateOcsp = 'true'
                    Uri                  = 'http://secondary-ocsp-responder/ocsp'
                }

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $singleRecordReturned }

                It 'Should return $false' {
                    $result = Test-TargetResource @presentParams

                    $result | Should -Be $false
                }
            }

            Context 'When ensure equals absent, but not in desired state, and OCSP record is returned' {
                $ocspRecordReturned = @(
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://secondary-ocsp-responder/ocsp'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $ocspRecordReturned }

                It 'Should return $false' {
                    $result = Test-TargetResource @absentParams

                    $result | Should -Be $false
                }
            }

            Context 'When ensure equals present, but not in desired state, and OCSP record # 3 contains a typographical error' {
                $wrongOcspRecordReturned = @(
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    }
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://secondary-ocsp-responder/ocsp'
                    }
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://tertiaryyy-ocsp-responder/ocsp'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $wrongOcspRecordReturned }

                It 'Should return $false' {
                    $result = Test-TargetResource @presentParams

                    $result | Should -Be $false
                }
            }

            Context 'When ensure equals present, but not in desired state, and counts do not match, and additional OCSP URI record returned' {
                $additionalOcspRecordReturned = @(
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://primary-ocsp-responder/ocsp'
                    }
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://secondary-ocsp-responder/ocsp'
                    }
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://tertiaryyy-ocsp-responder/ocsp'
                    }
                    @{
                        AddToCertificateAia  = 'false'
                        AddToCertificateOcsp = 'true'
                        Uri                  = 'http://rogue-ocsp-responder/ocsp'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $additionalOcspRecordReturned }

                It 'Should return $false' {
                    $result = Test-TargetResource @presentParams

                    $result | Should -Be $false
                }
            }
        }
    }
}

finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    Remove-Module -Name AdcsStub -Force
}
