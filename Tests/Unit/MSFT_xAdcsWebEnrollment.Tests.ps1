$script:DSCModuleName   = 'xAdcsDeployment'
$script:DSCResourceName = 'MSFT_xAdcsWebEnrollment'

#region HEADER
# Integration Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {
        $DummyCredential = New-Object System.Management.Automation.PSCredential ("Administrator",(New-Object -Type SecureString))

        Describe 'MSFT_xAdcsWebEnrollment\Get-TargetResource' {

            function Install-AdcsWebEnrollment {
                [cmdletbinding()]
                param($CAConfig,$Credential,[Switch]$Force,[Switch]$WhatIf)
            }
            function Uninstall-AdcsWebEnrollment {
                [cmdletbinding()]
                param([Switch]$Force)
            }

            #region Mocks
            Mock Install-AdcsWebEnrollment
            Mock Uninstall-AdcsWebEnrollment
            #endregion

            Context 'comparing Ensure' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    CAConfig = 'CA1.contoso.com\contoso-CA1-CA'
                    Credential = $DummyCredential
                }
                $Result = Get-TargetResource @Splat

                It 'should return StateOK false' {
                    $Result.Ensure | Should Be $Splat.Ensure
                    $Result.IsCAWeb | Should Be $False
                }

                It 'should call all mocks' {
                    Assert-MockCalled `
                        -commandName Install-AdcsWebEnrollment `
                        -Exactly 1
                }
            }
        }

        Describe 'MSFT_xAdcsWebEnrollment\Set-TargetResource' {

            function Install-AdcsWebEnrollment {
                [cmdletbinding()]
                param($CAConfig,$Credential,[Switch]$Force,[Switch]$WhatIf)
            }
            function Uninstall-AdcsWebEnrollment {
                [cmdletbinding()]
                param([Switch]$Force)
            }

            #region Mocks
            Mock Install-AdcsWebEnrollment
            Mock Uninstall-AdcsWebEnrollment
            #endregion

            Context 'testing Ensure Present' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    CAConfig = 'CA1.contoso.com\contoso-CA1-CA'
                    Credential = $DummyCredential
                }
                Set-TargetResource @Splat

                It 'should call install mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsWebEnrollment `
                        -Exactly 1
                    Assert-MockCalled `
                        -commandName Uninstall-AdcsWebEnrollment `
                        -Exactly 0
                }
            }

            Context 'testing Ensure Absent' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Absent'
                    CAConfig = 'CA1.contoso.com\contoso-CA1-CA'
                    Credential = $DummyCredential
                }
                Set-TargetResource @Splat

                It 'should call uninstall mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsWebEnrollment `
                        -Exactly 0
                    Assert-MockCalled `
                        -commandName Uninstall-AdcsWebEnrollment `
                        -Exactly 1
                }
            }
        }

        Describe 'MSFT_xAdcsWebEnrollment\Test-TargetResource' {

            function Install-AdcsWebEnrollment {
                [cmdletbinding()]
                param($CAConfig,$Credential,[Switch]$Force,[Switch]$WhatIf)
            }
            function Uninstall-AdcsWebEnrollment {
                [cmdletbinding()]
                param([Switch]$Force)
            }

            #region Mocks
            Mock Install-AdcsWebEnrollment
            Mock Uninstall-AdcsWebEnrollment
            #endregion

            Context 'testing ensure present' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    CAConfig = 'CA1.contoso.com\contoso-CA1-CA'
                    Credential = $DummyCredential
                }
                $Result = Test-TargetResource @Splat

                It 'should return false' {
                    $Result | Should be $False
                }
                It 'should call install mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsWebEnrollment `
                        -Exactly 1
                }
            }

            Context 'testing ensure absent' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Absent'
                    CAConfig = 'CA1.contoso.com\contoso-CA1-CA'
                    Credential = $DummyCredential
                }
                $Result = Test-TargetResource @Splat

                It 'should return true' {
                    $Result | Should be $True
                }
                It 'should call install mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsWebEnrollment `
                        -Exactly 1
                }
            }
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
