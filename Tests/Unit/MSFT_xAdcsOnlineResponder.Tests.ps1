$Global:DSCModuleName   = 'xAdcsDeployment'
$Global:DSCResourceName = 'MSFT_xAdcsOnlineResponder'

#region HEADER
if ( (-not (Test-Path -Path '.\DSCResource.Tests\')) -or `
     (-not (Test-Path -Path '.\DSCResource.Tests\TestHelper.psm1')) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git')
}
else
{
    & git @('-C',(Join-Path -Path (Get-Location) -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module .\DSCResource.Tests\TestHelper.psm1 -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 

# Install Test pre-requisites, automatically on appveyor
# by prompt locally
# to bypass prompts locally, set $ConfirmPreference = 'None'
function Install-TestPrerequisite
{
    [CmdletBinding( ConfirmImpact = 'high',  SupportsShouldProcess=$true)]
    param()
    # should check for the server OS
    if ($env:APPVEYOR_BUILD_VERSION -or $PSCmdlet.ShouldProcess(' Adcs-Cert-Authority','Install  Adcs-Cert-Authority WindowsFeature'))
    {
        Add-WindowsFeature Adcs-Cert-Authority -verbose
    }
}

Install-TestPrerequisite
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope MSFT_xAdcsOnlineResponder {

        Describe 'Get-TargetResource' {

            #region Mocks
            Mock Install-AdcsOnlineResponder 
            Mock Uninstall-AdcsOnlineResponder
            #endregion

            Context 'comparing Ensure' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    Credential = New-Object System.Management.Automation.PSCredential ("Administrator", (ConvertTo-SecureString 'NotReal' -AsPlainText -Force))
                }
                $Result = Get-TargetResource @Splat

                It 'should return StateOK false' {
                    $Result.Ensure | Should Be $Splat.Ensure
                    $Result.StateOK | Should Be $False
                }

                It 'should call all mocks' {
                    Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 1
                }
            }
        }

        Describe 'Set-TargetResource' {

            #region Mocks
            Mock Install-AdcsOnlineResponder
            Mock Uninstall-AdcsOnlineResponder
            #endregion

            Context 'testing Ensure Present' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    Credential = New-Object System.Management.Automation.PSCredential ("Administrator", (ConvertTo-SecureString 'NotReal' -AsPlainText -Force))
                }
                Set-TargetResource @Splat

                It 'should call install mock only' {
                    Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 1
                    Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Uninstall-AdcsOnlineResponder -Exactly 0
                }
            }

            Context 'testing Ensure Absent' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Absent'
                    Credential = New-Object System.Management.Automation.PSCredential ("Administrator", (ConvertTo-SecureString 'NotReal' -AsPlainText -Force))
                }
                Set-TargetResource @Splat

                It 'should call uninstall mock only' {
                    Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 0
                    Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Uninstall-AdcsOnlineResponder -Exactly 1
                }
            }
        }

        Describe 'Test-TargetResource' {

            #region Mocks
            Mock Install-AdcsOnlineResponder
            Mock Uninstall-AdcsOnlineResponder
            #endregion

            Context 'testing ensure present' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Present'
                    Credential = New-Object System.Management.Automation.PSCredential ("Administrator", (ConvertTo-SecureString 'NotReal' -AsPlainText -Force))
                }
                $Result = Test-TargetResource @Splat

                It 'should return false' {
                    $Result | Should be $False
                }
                It 'should call install mock only' {
                    Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 1
                }
            }

            Context 'testing ensure absent' {
                $Splat = @{
                    IsSingleInstance = 'Yes'
                    Ensure = 'Absent'
                    Credential = New-Object System.Management.Automation.PSCredential ("Administrator", (ConvertTo-SecureString 'NotReal' -AsPlainText -Force))
                }
                $Result = Test-TargetResource @Splat

                It 'should return true' {
                    $Result | Should be $True
                }
                It 'should call install mock only' {
                    Assert-MockCalled -ModuleName MSFT_xAdcsOnlineResponder -commandName Install-AdcsOnlineResponder -Exactly 1
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
