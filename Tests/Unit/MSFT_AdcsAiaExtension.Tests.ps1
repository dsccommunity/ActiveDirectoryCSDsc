Set-StrictMode -Version Latest

$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsAiaExtension'

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) ) {
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

# Import Stub function
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\TestHelpers\AdcsStub.psm1')

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit

try
{
    InModuleScope $DSCResourceName {
        $aiaUriList = @(
            'http://setAiaTest/Certs/<CATruncatedName>.cer'
            'http://setAiaTest2/Certs/<CATruncatedName>.cer'
            'file://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CaName><CertificateName>.crt'
        )

        $presentParams = @{
            AiaUri           = $aiaUriList
            Ensure           = 'Present'
            IsSingleInstance = 'Yes'
            RestartService   = $true
        }

        $setRestartServiceFalsePresentParams = @{
            AiaUri           = $aiaUriList
            Ensure           = 'Present'
            IsSingleInstance = 'Yes'
            RestartService   = $false
        }

        $absentParams = @{
            AiaUri           = $aiaUriList
            Ensure           = 'Absent'
            IsSingleInstance = 'Yes'
            RestartService   = $true
        }

        $setRestartServiceFalseAbsentParams = @{
            AiaUri           = $aiaUriList
            Ensure           = 'Absent'
            IsSingleInstance = 'Yes'
            RestartService   = $false
        }

        Describe "$DSCResourceName\Get-TargetResource" -Tag 'Get' {
            Context 'When the CA is installed and the Get-CAAuthorityInformationAccess cmdlet returns the AIA URI list' {
                $retreivedGetTargetValue = @{
                    AddToCertificateOcsp = 'false'
                    AddToCertificateAia  = 'true'
                    Uri                  = 'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                }

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -Mockwith { $retreivedGetTargetValue }

                It 'Should return a hashtable with the expected properties.' {
                    $result = Get-TargetResource @presentParams

                    $result                  | Should -Be System.Collections.Hashtable
                    $result.AiaUri           | Should -Be $retreivedGetTargetValue.Uri
                    $result.Ensure           | Should -Be $presentParams.Ensure
                    $result.IsSingleInstance | Should -Be $presentParams.IsSingleInstance
                    $result.RestartService   | Should -Be $presentParams.RestartService
                }
            }
        }

        Describe "$DSCResourceName\Set-TargetResource" -Tag 'Set' {
            Mock -CommandName Remove-CAAuthorityInformationAccess
            Mock -CommandName Add-CAAuthorityInformationAccess
            Mock -CommandName Restart-ServiceIfExists

            Context 'When ensure equals present, and AIA record is missing, and $RestartService equals $true' {
                $missingAiaUri = @{
                    AiaUri         = @(
                        'http://setAiaTest/Certs/<CATruncatedName>.cer'
                        'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                        'http://setAiaTest4/Certs/<CATruncatedName>.cer'
                    )
                    Ensure           = 'Present'
                    IsSingleInstance = 'Yes'
                    RestartService   = $true
                }

                Mock -CommandName Get-TargetResource -MockWith { $missingAiaUri }

                It 'Should call the expected mocks' {
                    Set-TargetResource @presentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $AiaUri -eq $presentParams.AiaUriList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $AiaUri -eq $presentParams.AiaUriList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 1 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }

            Context 'When ensure equals present, and AIA record is missing, and $RestartService equals $false' {
                $missingAiaUriRestartServiceFalse = @{
                    AiaUri           = @(
                        'http://setAiaTest/Certs/<CATruncatedName>.cer'
                        'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                    )
                    Ensure           = 'Present'
                    IsSingleInstance = 'Yes'
                    RestartService   = $false
                }

                Mock -CommandName Get-TargetResource -MockWith { $missingAiaUriRestartServiceFalse }

                It 'Should call the expected mocks' {
                    Set-TargetResource @setRestartServiceFalsePresentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 2 -Scope It -ParameterFilter { $AiaUri -eq $setRestartServiceFalsePresentParams.AiaUriList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $AiaUri -eq $setRestartServiceFalsePresentParams.AiaUriList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }

            Context 'When ensure equals absent, and AIA records are present, and $RestartService equals $true' {
                Mock -CommandName Get-TargetResource -MockWith { $presentParams }

                It 'Should call the expected mocks' {
                    Set-TargetResource @absentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $AiaUri -eq $absentParams.AiaUriList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 0 -Scope It -ParameterFilter { $AiaUri -eq $absentParams.AiaUriList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 1 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }

            Context 'When ensure equals absent, and AIA records are present, and $RestartService equals $false' {
                Mock -CommandName Get-TargetResource -MockWith { $setRestartServiceFalsePresentParams }

                It 'Should call the expected mocks' {
                    Set-TargetResource @setRestartServiceFalseAbsentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It -ParameterFilter { $AiaUri -eq $setRestartServiceFalseAbsentParams.AiaUriList }
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 0 -Scope It -ParameterFilter { $AiaUri -eq $setRestartServiceFalseAbsentParams.AiaUriList }
                    Assert-MockCalled -CommandName Restart-ServiceIfExists -Exactly -Times 0 -Scope It -ParameterFilter { $Name -eq 'CertSvc' }
                }
            }
        }

        Describe "$DSCResourceName\Test-TargetResource" -Tag 'Test' {
            Context 'When ensure equals present and in desired state' {
                $desiredStateRecordReturned = @(
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                    }
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest/Certs/<CATruncatedName>.cer'
                    }
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'file://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CaName><CertificateName>.crt'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $desiredStateRecordReturned }

                It 'Should return $true' {
                    Test-TargetResource @presentParams | Should -Be $true
                }
            }

            Context 'When ensure equals absent and in desired state' {
                $absentStateRecordReturned = @()

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $absentStateRecordReturned }

                It 'Should return $true' {
                    Test-TargetResource @absentParams | Should -Be $true
                }
            }

            Context 'When ensure equals present, but not in desired state, and no values stored in AIA records when passing in a value for AIA' {
                Mock -CommandName 'Get-CAAuthorityInformationAccess'

                It 'Should return $false' {
                    Test-TargetResource @presentParams | Should -Be $false
                }
            }

            Context 'When ensure equals present, but not in desired state, and different values are stored in AIA records when passing in a value for AIA' {
                $singleRecordReturned = @{
                    AddToCertificateOcsp = 'false'
                    AddToCertificateAia  = 'true'
                    Uri                  = 'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                }

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $singleRecordReturned }

                It 'Should return $false' {
                    Test-TargetResource @presentParams | Should -Be $false
                }
            }

            Context 'When ensure equals absent, but not in desired state, and AIA record is returned' {
                $aiaRecordReturned = @(
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $aiaRecordReturned }

                It 'Should return $false' {
                    Test-TargetResource @absentParams | Should -Be $false
                }
            }

            Context 'When ensure equals present, but not in desired state, and AIA record # 3 contains a typographical error' {
                $wrongAiaRecordReturned = @(
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                    }
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest/Certs/<CATruncatedName>.cer'
                    }
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://wrongAiaTest/Certs/<CATruncatedName>.cer'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $wrongAiaRecordReturned }

                It 'Should return $false' {
                    Test-TargetResource @presentParams | Should -Be $false
                }
            }

            Context 'When ensure equals present, but not in desired state, and counts do not match, and additional AIA URI record returned' {
                $additionalAiaRecordReturned = @(
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest2/Certs/<CATruncatedName>.cer'
                    }
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest/Certs/<CATruncatedName>.cer'
                    }
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://setAiaTest3/Certs/<CATruncatedName>.cer'
                    }
                    @{
                        AddToCertificateOcsp = 'false'
                        AddToCertificateAia  = 'true'
                        Uri                  = 'http://rogueAiaTest/Certs/<CATruncatedName>.cer'
                    }
                )

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $additionalAiaRecordReturned }

                It 'Should return $false' {
                    Test-TargetResource @presentParams | Should -Be $false
                }
            }
        }
    }
}

finally {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    Remove-Module -Name AdcsStub -Force
}
