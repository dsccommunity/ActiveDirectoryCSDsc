$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Get-Module MSFT_xAdcsOnlineResponder -All)
{
    Get-Module MSFT_xAdcsOnlineResponder -All | Remove-Module
}

Import-Module -Name $PSScriptRoot\..\DSCResources\MSFT_xAdcsOnlineResponder  -Force -DisableNameChecking

# should check for the server OS
if($env:APPVEYOR_BUILD_VERSION)
{
  Add-WindowsFeature Adcs-Cert-Authority -verbose
}

InModuleScope MSFT_xAdcsOnlineResponder {

    Describe 'Get-TargetResource' {

        #region Mocks
        Mock Install-AdcsOnlineResponder {}
        #endregion

        Context 'comparing Ensure' {
            $Splat = @{
                Ensure = 'Present'
                Name = 'Test'
            }
            $Result = Get-TargetResource @Splat

            It 'should return false' {
                $Result.Ensure | Should Be $Splat.Ensure
                $Result.IsResponder | Should Be $False
            }

            It 'should call all mocks' {
                Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 1
            }
        }
    }

    Describe 'Set-TargetResource' {

        #region Mocks
        Mock Install-AdcsOnlineResponder {}
        Mock Uninstall-AdcsOnlineResponder {}
        #endregion

        Context 'testing Ensure Present' {
            $Splat = @{
                Ensure = 'Present'
                Name = 'Test'
            }
            Set-TargetResource @Splat

            It 'should call install mock only' {
                Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 1
                Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Uninstall-AdcsOnlineResponder -Exactly 0
            }
        }

        Context 'testing Ensure Absent' {
            $Splat = @{
                Ensure = 'Absent'
                Name = 'Test'
            }
            Set-TargetResource @Splat

            It 'should call uninstall mock only' {
                Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 0
                Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Uninstall-AdcsOnlineResponder -Exactly 1
            }
        }
    }
}