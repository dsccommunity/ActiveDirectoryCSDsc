Set-StrictMode -Version Latest

$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsOcspExtension'

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
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

        Describe "$DSCResourceName\Get-TargetResource" -Tag 'Get' {

            Context 'Normal Operations' {

                $retreivedGetTargetValue = @{
                    AddToCertificateAia  = 'false'
                    AddToCertificateOcsp = 'true'
                    Uri                  = 'http://primary-ocsp-responder/ocsp'
                }

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -Mockwith { $retreivedGetTargetValue }

                It 'Should return a hashtable' {

                    $result = Get-TargetResource @presentParams

                    $result | Should -Be System.Collections.Hashtable
                }

                It 'Returns all properties as expected.' {

                    $result = Get-TargetResource @presentParams

                    $result.OcspUriPath      | Should -Be $retreivedGetTargetValue.Uri
                    $result.Ensure           | Should -Be $presentParams.Ensure
                    $result.IsSingleInstance | Should -Be $presentParams.IsSingleInstance
                    $result.RestartService   | Should -Be $presentParams.RestartService
                }
            }
        }

        Describe "$DSCResourceName\Set-TargetResource" -Tag 'Set' {

            Mock -CommandName Remove-CAAuthorityInformationAccess
            Mock -CommandName Add-CAAuthorityInformationAccess
            Mock -CommandName Restart-SystemService

            Context 'Ensure equals present - Ocsp record missing - restart service set to $true' {

                $missingOcspUriPath  = @{
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

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 2 -Scope It
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It
                    Assert-MockCalled -CommandName Restart-SystemService -Exactly -Times 1 -Scope It
                }
            }

            Context 'Ensure equals present - Ocsp record missing - restart service set to $false' {

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

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 2 -Scope It
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It
                    Assert-MockCalled -CommandName Restart-SystemService -Exactly -Times 0 -Scope It
                }
            }

            Context 'Ensure equals absent - Ocsp records present - restart service set to $true' {

                Mock -CommandName Get-TargetResource -MockWith { $presentParams }

                It 'Should call the expected mocks' {

                    Set-TargetResource @absentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 0 -Scope It
                    Assert-MockCalled -CommandName Restart-SystemService -Exactly -Times 1 -Scope It
                }
            }

            Context 'Ensure equals absent - Ocsp records present - restart service set to $false' {

                Mock -CommandName Get-TargetResource -MockWith { $setRestartServiceFalsePresentParams }

                It 'Should call the expected mocks' {

                    Set-TargetResource @setRestartServiceFalseAbsentParams

                    Assert-MockCalled -CommandName Remove-CAAuthorityInformationAccess -Exactly -Times 3 -Scope It
                    Assert-MockCalled -CommandName Add-CAAuthorityInformationAccess -Exactly -Times 0 -Scope It
                    Assert-MockCalled -CommandName Restart-SystemService -Exactly -Times 0 -Scope It
                }
            }
        }

        Describe "$DSCResourceName\Test-TargetResource" -Tag 'Test' {

            Context 'Ensure equals Present - In desired state' {

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

            Context 'Ensure equals Absent - In desired state' {

                $absentStateRecordReturned = @()

                Mock -CommandName 'Get-CAAuthorityInformationAccess' -MockWith { $absentStateRecordReturned }

                It 'Should return $true' {

                    $result = Test-TargetResource @absentParams

                    $result | Should -Be $true
                }
            }

            Context 'Ensure equals Present - Not in desired state - No values stored in Ocsp records when passing in a value for Ocsp' {

                Mock -CommandName 'Get-CAAuthorityInformationAccess' { $null }

                It 'Should return $false' {

                    $result = Test-TargetResource @presentParams

                    $result | Should -Be $false
                }
            }

            Context 'Not in desired state - Different values stored in Ocsp records when passing in a value for Ocsp' {

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

            Context 'Not in desired state - Ensure equals absent, Ocsp record returned' {

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

            Context 'Not in desired state - Ensure equals Present, Ocsp record # 3 contains typo' {

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

            Context 'Not in desired state - Ensure equals Present, Counts do not match, additional Ocsp Uri record returned' {

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
