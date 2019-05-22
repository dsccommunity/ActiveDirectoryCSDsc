$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsTemplate'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Integration Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
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

Try
{
    InModuleScope $script:DSCResourceName {

        $MockTemplateList = @(
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
                Oid = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.28'
            }
            @{
                Name = 'KerberosAuthentication'
                Oid = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.33'
            }
        )

        $testTemplatePresent = @{
            Name   = 'User'
            Ensure = 'Present'
        }

        $testTemplateNotPresent = @{
            Name   = 'EFS'
            Ensure = 'Present'
        }

        $testTemplateNotAbsent = @{
            Name   = 'User'
            Ensure = 'Absent'
        }

        $testTemplateAbsent = @{
            Name   = 'EFS'
            Ensure = 'Absent'
        }

        function Get-CATemplate
        {
            [CmdletBinding()]
            param
            ()
        }

        function Add-CATemplate
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true)]
                [String]
                $Name
            )
        }

        function Remove-CATemplate
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true)]
                [String]
                $Name,

                [Parameter()]
                [switch]
                $Force
            )
        }

        Describe "$DSCResourceName\Get-TargetResource" {
            Context 'Template is installed' {
                Mock -CommandName Get-CATemplate -MockWith { $MockTemplateList }

                $result = Get-TargetResource @testTemplatePresent

                It 'Should return Ensure set to Present' {
                    $result.Ensure | Should -Be 'Present'
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock

                    Assert-MockCalled `
                        -CommandName Get-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'Template is not installed' {
                Mock -CommandName Get-CATemplate -MockWith { $MockTemplateList }

                $result = Get-TargetResource @testTemplateNotPresent

                It 'Should return Ensure set to Absent' {
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Get-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }
        }
        Describe "$DSCResourceName\Set-TargetResource" {
            Context 'Template is not added but should be' {
                Mock -CommandName Add-CATemplate -MockWith { }

                It 'Should not throw an exception' {
                    { Set-TargetResource @testTemplateNotPresent } | Should Not Throw
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Add-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'Template is added but should not be' {
                Mock -CommandName Remove-CATemplate -MockWith { }

                It 'Should not throw an exception' {
                    { Set-TargetResource @testTemplateNotAbsent } | Should Not Throw
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Remove-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }
        }
        Describe "$DSCResourceName\Test-TargetResource" {
            Context 'Template is added and should be' {
                Mock -CommandName Get-CATemplate -MockWith { $MockTemplateList }

                $result = Test-TargetResource @testTemplatePresent

                It 'Should return true' {
                    $result | Should -Be $true
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'Template is added and should not be' {
                Mock -CommandName Get-CATemplate -MockWith { $MockTemplateList }

                $result = Test-TargetResource @testTemplateNotAbsent

                It 'Should return false' {
                    $result | Should -Be $false
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'Template is not added and should be' {
                Mock -CommandName Get-CATemplate -MockWith { $MockTemplateList }

                $result = Test-TargetResource @testTemplateNotPresent

                It 'Should return false' {
                    $result | Should -Be $false
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'Template is not added and should not be' {
                Mock -CommandName Get-CATemplate -MockWith { $MockTemplateList }

                $result = Test-TargetResource @testTemplateAbsent

                It 'Should return true' {
                    $result | Should -Be $true
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-CATemplate `
                        -Exactly `
                        -Times 1
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
