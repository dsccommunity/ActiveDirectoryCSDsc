Set-StrictMode -Version Latest

$script:moduleName = 'ActiveDirectoryCSDsc.CommonHelper'

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent) -ChildPath 'Modules\ActiveDirectoryCSDsc.CommonHelper\ActiveDirectoryCSDsc.CommonHelper.psm1') -Scope Global -Force

InModuleScope $script:moduleName {
    $getServiceParameterFilter = @{
        Status      = 'Running'
        Name        = 'Servsvc'
        DisplayName = 'Service service'
    }

    $restartServiceIfExistsParams = @{
        Name = 'BITS'
    }

    Describe "$script:moduleName\Restart-SystemService" {
        Mock -CommandName Restart-Service

        Context 'When service does not exist and is not restarted' {
            Mock -CommandName Get-Service

            It 'Should call the expected mocks' {
                Restart-ServiceIfExists @restartServiceIfExistsParams
                Assert-MockCalled Get-Service -Exactly -Times 1 -Scope It -ParameterFilter { $Name -eq $restartServiceIfExistsParams.Name }
                Assert-MockCalled Restart-Service -Exactly -Times 0 -Scope It
            }
        }

        Context 'When service exists and will be restarted' {
            Mock -CommandName Get-Service -MockWith {return $getServiceParameterFilter}

            It 'Should call the expected mocks' {
                Restart-ServiceIfExists @restartServiceIfExistsParams
                Assert-MockCalled Get-Service -Exactly -Times 1 -Scope It -ParameterFilter { $Name -eq $restartServiceIfExistsParams.Name }
                Assert-MockCalled Restart-Service -Exactly -Times 1 -Scope It
            }
        }
    }
}
