Set-StrictMode -Version Latest

$script:moduleName = 'ActiveDirectoryCSDsc.ResourceHelper'

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent) -ChildPath 'Modules\ActiveDirectoryCSDsc.ResourceHelper\ActiveDirectoryCSDsc.ResourceHelper.psm1') -Scope Global -Force

InModuleScope $script:moduleName {

    $inputParam1 = @{
        Status      = 'Running'
        Name        = 'Servsvc'
        DisplayName = 'Service service'
    }

    $inputParam2  = @{
        serviceName = 'BITS'
    }

    Describe "$script:moduleName\Restart-SystemService" {

        Mock -CommandName Restart-Service

        Context "Service does not exist and is not restarted" {

            Mock -CommandName Get-Service -MockWith {return $null}

            It 'Should call the expected mocks' {
                Restart-SystemService @inputParam2
                Assert-MockCalled Get-Service -Exactly -Times 1 -Scope It
                Assert-MockCalled Restart-Service -Exactly -Times 0 -Scope It
            }
        }

        Context "Service exists and will be restarted" {

            Mock -CommandName Get-Service -MockWith {return $inputParam1}

            It 'Should call the expected mocks' {
                Restart-SystemService @inputParam2
                Assert-MockCalled Get-Service -Exactly -Times 1 -Scope It
                Assert-MockCalled Restart-Service -Exactly -Times 1 -Scope It
            }
        }

        Context "Service does not exist and is not restarted" {

            Mock -CommandName Get-Service -MockWith {return $null}

            It 'Should call the expected mocks' {
                Restart-SystemService @inputParam2
                Assert-MockCalled Get-Service -Exactly -Times 1 -Scope It
                Assert-MockCalled Restart-Service -Exactly -Times 0 -Scope It
            }
        }
    }
}
