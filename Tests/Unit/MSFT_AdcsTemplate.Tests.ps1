$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsTemplate'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

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

Try
{
    InModuleScope $script:DSCResourceName {
        $mockTemplateList = @(
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
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.28'
            }
            @{
                Name = 'KerberosAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.33'
            }
        )

        $testTemplatePresent = @{
            Name = 'User'
        }

        $testTemplateNotPresent = @{
            Name = 'EFS'
        }

        $mockGetTemplatePresent = @{
            Name   = 'User'
            Ensure = 'Present'
        }

        $mockGetTemplateNotPresent = @{
            Name   = 'EFS'
            Ensure = 'Absent'
        }

        function Get-CATemplate
        {
            [CmdletBinding()]
            param ()
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

        Describe 'MSFT_AdcsTemplate\Get-TargetResource' {
            Context 'When the template is installed' {
                Mock -CommandName Get-CATemplate -MockWith { $mockTemplateList }

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

            Context 'When the template is not installed' {
                Mock -CommandName Get-CATemplate -MockWith { $mockTemplateList }

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

            Context 'When Get-CATemplate throws an exception' {
                Mock -CommandName Get-CATemplate -MockWith { throw }

                It 'Should throw the correct error' {
                    $errorRecord = Get-InvalidOperationRecord `
                        -Message $script:localizedData.InvalidOperationGettingAdcsTemplateMessage
                    { Get-TargetResource @testTemplatePresent } | Should -Throw $errorRecord
                }
            }
        }

        Describe 'MSFT_AdcsTemplate\Set-TargetResource' {
            Context 'When the template is not added but should be' {
                Mock -CommandName Add-CATemplate

                It 'Should not throw an exception' {
                    { Set-TargetResource @testTemplateNotPresent } | Should Not Throw
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Add-CATemplate `
                        -ParameterFilter { $Name -eq $testTemplateNotPresent.Name } `
                        -Exactly `
                        -Times 1
                }

                Context 'When Add-CATemplate throws an exception' {
                    Mock -CommandName Add-CATemplate -MockWith { throw }

                    It 'Should throw the correct error' {
                        $errorRecord = Get-InvalidOperationRecord `
                            -Message ($script:localizedData.InvalidOperationAddingAdcsTemplateMessage -f $testTemplateNotPresent.Name)
                        { Set-TargetResource @testTemplateNotPresent } | Should -Throw $errorRecord
                    }
                }

                Context 'When the template is added but should not be' {
                    Mock -CommandName Remove-CATemplate

                    It 'Should not throw an exception' {
                        { Set-TargetResource @testTemplatePresent -Ensure 'Absent' } | Should Not Throw
                    }

                    It 'Should call expected mock' {
                        Assert-MockCalled `
                            -CommandName Remove-CATemplate `
                            -ParameterFilter { $Name -eq $testTemplatePresent.Name } `
                            -Exactly `
                            -Times 1
                    }
                }

                Context 'When Remove-CATemplate throws an exception' {
                    Mock -CommandName Remove-CATemplate -MockWith { throw }

                    It 'Should throw the correct error' {
                        $errorRecord = Get-InvalidOperationRecord `
                            -Message ($script:localizedData.InvalidOperationRemovingAdcsTemplateMessage -f $testTemplatePresent.Name)
                        { Set-TargetResource @testTemplatePresent -Ensure 'Absent' } | Should -Throw $errorRecord
                    }
                }
            }
        }

        Describe 'MSFT_AdcsTemplate\Test-TargetResource' {
            Context 'When the template is added and should be' {
                Mock -CommandName Get-TargetResource -MockWith { $mockGetTemplatePresent }

                $result = Test-TargetResource @testTemplatePresent -Ensure 'Present'

                It 'Should return true' {
                    $result | Should -Be $true
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-TargetResource `
                        -ParameterFilter { $Name -eq $testTemplatePresent.Name } `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the template is added and should not be' {
                Mock -CommandName Get-TargetResource -MockWith { $mockGetTemplatePresent }

                $result = Test-TargetResource @testTemplatePresent -Ensure 'Absent'

                It 'Should return false' {
                    $result | Should -Be $false
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-TargetResource `
                        -ParameterFilter { $Name -eq $testTemplatePresent.Name } `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the template is not added and should be' {
                Mock -CommandName Get-TargetResource -MockWith { $mockGetTemplateNotPresent }

                $result = Test-TargetResource @testTemplateNotPresent -Ensure 'Present'

                It 'Should return false' {
                    $result | Should -Be $false
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-TargetResource `
                        -ParameterFilter { $Name -eq $testTemplateNotPresent.Name } `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the template is not added and should not be' {
                Mock -CommandName Get-TargetResource -MockWith { $MockGetTemplateNotPresent }

                $result = Test-TargetResource @testTemplateNotPresent -Ensure 'Absent'

                It 'Should return true' {
                    $result | Should -Be $true
                }

                It 'Should call expected mock' {
                    Assert-MockCalled `
                        -CommandName Get-TargetResource `
                        -ParameterFilter { $Name -eq $testTemplateNotPresent.Name } `
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
