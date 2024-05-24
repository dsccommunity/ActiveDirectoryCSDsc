<#
    .SYNOPSIS
        Unit test for DSC_AdcsCertificationAuthority DSC resource.

    .NOTES
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'ActiveDirectoryCSDsc'
    $script:dscResourceName = 'DSC_AdcsCertificationAuthority'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
    #Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\Stubs\AdcsAdministrationStub.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\Stubs\AdcsDeploymentStub.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName

    # Add Custom Type
    if (-not ([System.Management.Automation.PSTypeName]'Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException').Type)
    {
        <#
                Define the exception class:
                Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException
                so that unit tests can be run without ADCS being installed.
            #>

        $exceptionDefinition = @'
namespace Microsoft.CertificateServices.Deployment.Common.CA {
    public class CertificationAuthoritySetupException: System.Exception {
    }
}
'@
        Add-Type -TypeDefinition $exceptionDefinition
    }

    # Add Test Data
    InModuleScope -ScriptBlock {
        $dummyCredential = New-Object System.Management.Automation.PSCredential ('Administrator', (New-Object -Type SecureString))

        $script:testParametersPresent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            CAType           = 'StandaloneRootCA'
            Credential       = $dummyCredential
            Verbose          = $false
        }

        $script:testParametersAbsent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Absent'
            CAType           = 'StandaloneRootCA'
            Credential       = $dummyCredential
            Verbose          = $false
        }
    }
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    #Remove-Module -Name AdcsAdministrationStub -Force
    Remove-Module -Name AdcsDeploymentStub -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}


Describe 'DSC_AdcsCertificationAuthority\Get-TargetResource' -Tag 'Get' {
    Context 'When the CA is installed' {
        BeforeAll {
            Mock `
                -CommandName Install-AdcsCertificationAuthority `
                -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException') } `
                -Verifiable
        }


        It 'Should return Ensure set to Present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Get-TargetResource @script:testParametersPresent
                $result.Ensure | Should -Be 'Present'
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable

            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When the CA is not installed' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority
        }


        It 'Should return Ensure set to Absent' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Get-TargetResource @script:testParametersPresent
                $result.Ensure | Should -Be 'Absent'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When there is an unexpected error' {
        BeforeAll {
            Mock `
                -CommandName Install-AdcsCertificationAuthority `
                -MockWith { Throw (New-Object -TypeName 'System.Exception') } `
                -Verifiable
        }

        It 'Should throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Get-TargetResource @script:testParametersPresent } | Should -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable

            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsCertificationAuthority\Set-TargetResource' -Tag 'Set' {
    Context 'When the CA is not installed but should be' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority
            Mock -CommandName Uninstall-AdcsCertificationAuthority
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @script:testParametersPresent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsCertificationAuthority `
                -Exactly `
                -Times 0 -Scope Context
        }
    }

    Context 'When the CA is not installed but should be but an error is thrown installing it' {
        BeforeAll {
            Mock `
                -CommandName Install-AdcsCertificationAuthority `
                -MockWith { [PSObject] @{ErrorString = 'Something went wrong' } }

            Mock -CommandName Uninstall-AdcsCertificationAuthority
        }

        It 'Should throw exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                { Set-TargetResource @testParametersPresent } | Should -Throw $errorRecord
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsCertificationAuthority `
                -Exactly `
                -Times 0 -Scope Context
        }
    }

    Context 'When CA is multi tier and error should not throw for ErrorString with specific text' {
        BeforeAll {
            Mock `
                -CommandName Install-AdcsCertificationAuthority `
                -MockWith { [PSObject] @{ ErrorString = 'The Active Directory Certificate Services installation is incomplete' } }
        }

        It 'Should not throw exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @testParametersPresent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When CA is multi tier and error should not throw for Error ID 398' {
        BeforeAll {
            Mock `
                -CommandName Install-AdcsCertificationAuthority `
                -MockWith { [PSObject] @{
                    ErrorID     = 398
                    ErrorString = 'Something went wrong'
                } }
        }

        It 'Should not throw exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @testParametersPresent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When the CA is installed but should not be' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority
            Mock -CommandName Uninstall-AdcsCertificationAuthority
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @testParametersAbsent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 0 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsCertificationAuthority\Test-TargetResource' -Tag 'Test' {
    Context 'When the CA is installed and should be' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority `
                -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException') } `
                -Verifiable
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Test-TargetResource @testParametersPresent
                $result | Should -BeTrue
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When the CA is installed but should not be' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority `
                -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException') } `
                -Verifiable
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Test-TargetResource @testParametersAbsent
                $result | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When the CA is not installed but should be' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority `
                -Verifiable
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Test-TargetResource @testParametersPresent
                $result | Should -BeFalse
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When the CA is not installed and should not be' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority `
                -Verifiable
        }


        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Test-TargetResource @testParametersAbsent
                $result | Should -BeTrue
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'Should throw on any other error' {
        BeforeAll {
            Mock -CommandName Install-AdcsCertificationAuthority `
                -MockWith { Throw (New-Object -TypeName 'System.Exception') } `
                -Verifiable
        }

        It 'Should throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Test-TargetResource @testParametersPresent } | Should -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable
            Should -Invoke `
                -CommandName Install-AdcsCertificationAuthority `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}
