$script:DSCModuleName   = 'xAdcsDeployment'
$script:DSCResourceName = 'MSFT_xAdcsOnlineResponder'

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
        $DSCResourceName = 'MSFT_xAdcsOnlineResponder'

        $DummyCredential = New-Object System.Management.Automation.PSCredential ("Administrator",(New-Object -Type SecureString))

        Describe "$DSCResourceName\Get-TargetResource" {

            function Install-AdcsOnlineResponder {
                [CmdletBinding()]
                param($Credential,[Switch]$Force,[Switch]$WhatIf)
            }
            function Uninstall-AdcsOnlineResponder {
                [CmdletBinding()]
                param([Switch]$Force)
            }

            #region Mocks
            Mock Install-AdcsOnlineResponder
            Mock Uninstall-AdcsOnlineResponder
            #endregion

            Context 'comparing Ensure' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    Credential = $DummyCredential
                }
                $Result = Get-TargetResource @Splat

                It 'should return StateOK false' {
                    $Result.Ensure | Should Be $Splat.Ensure
                    $Result.StateOK | Should Be $False
                }

                It 'should call all mocks' {
                    Assert-MockCalled `
                        -commandName Install-AdcsOnlineResponder `
                        -Exactly 1
                }
            }
        }

        Describe "$DSCResourceName\Set-TargetResource" {

            function Install-AdcsOnlineResponder {
                [CmdletBinding()]
                param($Credential,[Switch]$Force,[Switch]$WhatIf)
            }
            function Uninstall-AdcsOnlineResponder {
                [CmdletBinding()]
                param([Switch]$Force)
            }

            #region Mocks
            Mock Install-AdcsOnlineResponder
            Mock Uninstall-AdcsOnlineResponder
            #endregion

            Context 'testing Ensure Present' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    Credential = $DummyCredential
                }
                Set-TargetResource @Splat

                It 'should call install mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsOnlineResponder `
                        -Exactly 1
                    Assert-MockCalled `
                        -commandName Uninstall-AdcsOnlineResponder `
                        -Exactly 0
                }
            }

            Context 'testing Ensure Absent' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Absent'
                    Credential = $DummyCredential
                }
                Set-TargetResource @Splat

                It 'should call uninstall mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsOnlineResponder `
                        -Exactly 0
                    Assert-MockCalled `
                        -commandName Uninstall-AdcsOnlineResponder `
                        -Exactly 1
                }
            }
        }

        Describe "$DSCResourceName\Test-TargetResource" {

            function Install-AdcsOnlineResponder {
                [CmdletBinding()]
                param($Credential,[Switch]$Force,[Switch]$WhatIf)
            }
            function Uninstall-AdcsOnlineResponder {
                [CmdletBinding()]
                param([Switch]$Force)
            }

            #region Mocks
            Mock Install-AdcsOnlineResponder
            Mock Uninstall-AdcsOnlineResponder
            #endregion

            Context 'testing ensure present' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    Credential = $DummyCredential
                }
                $Result = Test-TargetResource @Splat

                It 'should return false' {
                    $Result | Should be $False
                }
                It 'should call install mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsOnlineResponder `
                        -Exactly 1
                }
            }

            Context 'testing ensure absent' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Absent'
                    Credential = $DummyCredential
                }
                $Result = Test-TargetResource @Splat

                It 'should return true' {
                    $Result | Should be $True
                }
                It 'should call install mock only' {
                    Assert-MockCalled `
                        -commandName Install-AdcsOnlineResponder `
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
