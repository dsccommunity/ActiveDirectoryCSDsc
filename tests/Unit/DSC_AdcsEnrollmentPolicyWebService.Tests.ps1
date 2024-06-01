<#
    .SYNOPSIS
        Unit test for DSC_AdcsEnrollmentPolicyWebService DSC resource.

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
    $script:dscResourceName = 'DSC_AdcsEnrollmentPolicyWebService'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\Stubs\AdcsDeploymentStub.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName

    # Add Custom Type
    if (-not ([System.Management.Automation.PSTypeName]'Microsoft.CertificateServices.Deployment.Commands.CEP.EnrollmentPolicyServiceSetupException').Type)
    {
        <#
                Define the exception class:
                Microsoft.CertificateServices.Deployment.Commands.CEP.EnrollmentPolicyServiceSetupException
                so that unit tests can be run without ADCS being installed.
            #>

        $ExceptionDefinition = @'
namespace Microsoft.CertificateServices.Deployment.Commands.CEP {
    public class EnrollmentPolicyServiceSetupException: System.Exception {
    }
}
'@
        Add-Type -TypeDefinition $ExceptionDefinition
    }

    # Test Data
    InModuleScope -ScriptBlock {
        $dummyCredential = New-Object `
            -TypeName System.Management.Automation.PSCredential `
            -ArgumentList ('Administrator', (New-Object -TypeName SecureString))

        $script:testParametersPresent = @{
            AuthenticationType = 'Certificate'
            SslCertThumbprint  = 'B2E43FF3E02D1EE767C06BD905F292E33BD14C1A'
            Credential         = $dummyCredential
            KeyBasedRenewal    = $true
            Ensure             = 'Present'
            Verbose            = $false
        }

        $script:testParametersAbsent = $testParametersPresent.Clone()
        $script:testParametersAbsent.Ensure = 'Absent'

        $script:testParametersGet = @{
            AuthenticationType = 'Certificate'
            SslCertThumbprint  = 'B2E43FF3E02D1EE767C06BD905F292E33BD14C1A'
            Credential         = $dummyCredential
            KeyBasedRenewal    = $true
            Verbose            = $false
        }

        $script:invalidThumbprint = 'Zebra'

        # This thumbprint is valid (but not FIPS valid)
        $script:validThumbprint = (
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | Where-Object {
                $_.BaseType.BaseType -eq [System.Security.Cryptography.HashAlgorithm] -and
                ($_.Name -cmatch 'Managed$' -or $_.Name -cmatch 'Provider$')
            } | Select-Object -First 1 | ForEach-Object {
                (New-Object $_).ComputeHash([String]::Empty) | ForEach-Object {
                    '{0:x2}' -f $_
                }
            }
        ) -join ''

        # This thumbprint is valid for FIPS
        $script:validFipsThumbprint = (
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | Where-Object {
                $_.BaseType.BaseType -eq [System.Security.Cryptography.HashAlgorithm] -and
                ($_.Name -cmatch 'Provider$' -and $_.Name -cnotmatch 'MD5')
            } | Select-Object -First 1 | ForEach-Object {
                (New-Object $_).ComputeHash([String]::Empty) | ForEach-Object {
                    '{0:x2}' -f $_
                }
            }
        ) -join ''
    }
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    Remove-Module -Name AdcsDeploymentStub -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe 'DSC_AdcsEnrollmentPolicyWebService\Get-TargetResource' -Tag 'Get' {
    Context 'When the Enrollment Policy Web Service is installed' {
        BeforeAll {
            Mock `
                -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                -MockWith { $true }
        }


        It 'Should return Ensure set to Present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Get-TargetResource @testParametersGet
                $result.Ensure | Should -Be 'Present'
            }
        }

        It 'Should call expected mocks' {
            Should -InvokeVerifiable

            Should -Invoke `
                -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                -Exactly `
                -Times 1 -Scope Context
        }
    }

    Context 'When the Enrollment Policy Web Service is not installed' {
        BeforeAll {
            Mock `
                -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                -MockWith { $false }
        }


        It 'Should return Ensure set to Absent' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Get-TargetResource @testParametersGet
                $result.Ensure | Should -Be 'Absent'
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsEnrollmentPolicyWebService\Set-TargetResource' -Tag 'Set' {
    Context 'When the Enrollment Policy Web Service is not installed but should be' {
        BeforeAll {
            Mock -CommandName Install-AdcsEnrollmentPolicyWebService
            Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @testParametersPresent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 0 -Scope Context
        }
    }

    Context 'When the Enrollment Policy Web Service is not installed but should be but an error string is returned installing it' {
        BeforeAll {
            Mock -CommandName Install-AdcsEnrollmentPolicyWebService `
                -MockWith {
                [PSObject] @{ ErrorString = 'Something went wrong' }
            }

            Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                { Set-TargetResource @testParametersPresent } | Should -Throw $errorRecord
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 0 -Scope Context
        }
    }

    Context 'When the Enrollment Policy Web Service is not installed but should be but an exception is thrown installing it' {
        BeforeAll {
            Mock -CommandName Install-AdcsEnrollmentPolicyWebService `
                -MockWith { throw 'Something went wrong' }

            Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                { Set-TargetResource @testParametersPresent } | Should -Throw $errorRecord
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 0 -Scope Context
        }
    }

    Context 'When the Enrollment Policy Web Service is installed but should not be' {
        BeforeAll {
            Mock -CommandName Install-AdcsEnrollmentPolicyWebService
            Mock -CommandName Uninstall-AdcsEnrollmentPolicyWebService
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { Set-TargetResource @testParametersAbsent } | Should -Not -Throw
            }
        }

        It 'Should call expected mocks' {
            Should -Invoke `
                -CommandName Install-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 0 -Scope Context

            Should -Invoke `
                -CommandName Uninstall-AdcsEnrollmentPolicyWebService `
                -Exactly `
                -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsEnrollmentPolicyWebService\Test-TargetResource' -Tag 'Test' {
    Context 'When the Enrollment Policy Web Service is installed' {
        Context 'When the Enrollment Policy Web Service should be installed' {
            BeforeAll {
                Mock `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -MockWith { $true }
            }


            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource @testParametersPresent
                    $result | Should -BeTrue
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }

        Context 'When the Enrollment Policy Web Service should not be installed' {
            BeforeAll {
                Mock `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -MockWith { $true }
            }


            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource @testParametersAbsent
                    $result | Should -BeFalse
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }
    }

    Context 'When the Enrollment Policy Web Service is not installed' {
        Context 'When the Enrollment Policy Web Service should be installed' {
            BeforeAll {
                Mock `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -MockWith { $false }
            }


            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource @testParametersPresent
                    $result | Should -BeFalse
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }

        Context 'When the Enrollment Policy Web Service should not be installed' {
            BeforeAll {
                Mock `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -MockWith { $false }
            }

            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource @testParametersAbsent
                    $result | Should -BeTrue
                }
            }

            It 'Should call expected mocks' {
                Should -Invoke `
                    -CommandName Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -Exactly `
                    -Times 1 -Scope Context
            }
        }
    }
}

Describe 'DSC_AdcsEnrollmentPolicyWebService\Test-AdcsEnrollmentPolicyWebServiceInstallState' -Tag 'Private' {
    BeforeDiscovery {
        $script:testAdcsEnrollmentPolicyWebServiceInstallStateTestCases = @(
            @{
                AuthenticationType = 'Certificate'
                KeyBasedRenewal    = $false
                WebAppName         = 'ADPolicyProvider_CEP_Certificate'
                Applicationpool    = 'WSEnrollmentPolicyServer'
                PhysicalPath       = 'C:\Windows\SystemData\CEP\ADPolicyProvider_CEP_Certificate'
            },
            @{
                AuthenticationType = 'Certificate'
                KeyBasedRenewal    = $true
                WebAppName         = 'KeyBasedRenewal_ADPolicyProvider_CEP_Certificate'
                Applicationpool    = 'WSEnrollmentPolicyServer'
                PhysicalPath       = 'C:\Windows\SystemData\CEP\KeyBasedRenewal_ADPolicyProvider_CEP_Certificate'
            },
            @{
                AuthenticationType = 'Kerberos'
                KeyBasedRenewal    = $false
                WebAppName         = 'ADPolicyProvider_CEP_Kerberos'
                Applicationpool    = 'WSEnrollmentPolicyServer'
                PhysicalPath       = 'C:\Windows\SystemData\CEP\ADPolicyProvider_CEP_Kerberos'
            },
            @{
                AuthenticationType = 'UserName'
                KeyBasedRenewal    = $false
                WebAppName         = 'ADPolicyProvider_CEP_UsernamePassword'
                Applicationpool    = 'WSEnrollmentPolicyServer'
                PhysicalPath       = 'C:\Windows\SystemData\CEP\ADPolicyProvider_CEP_UsernamePassword'
            },
            @{
                AuthenticationType = 'UserName'
                KeyBasedRenewal    = $true
                WebAppName         = 'KeyBasedRenewal_ADPolicyProvider_CEP_UsernamePassword'
                Applicationpool    = 'WSEnrollmentPolicyServer'
                PhysicalPath       = 'C:\Windows\SystemData\CEP\KeyBasedRenewal_ADPolicyProvider_CEP_UsernamePassword'
            }
        )
    }
    BeforeAll {
        $script:mockAdcsEnrollmentPolicyWebServiceInstallStateAllInstalled = { $testAdcsEnrollmentPolicyWebServiceInstallStateTestCases }

        $script:mockAdcsEnrollmentPolicyWebServiceInstallStateNoneInstalled = { @() }
    }

    Context 'When matching Enrollment Policy Web Service is installed' {
        BeforeEach {
            Mock `
                -CommandName Get-WebApplication `
                -MockWith $mockAdcsEnrollmentPolicyWebServiceInstallStateAllInstalled
        }

        It 'Given AuthenticationType <AuthenticationType> and KeyBasedRenewal <KeyBasedRenewal> it should return $true' -ForEach $testAdcsEnrollmentPolicyWebServiceInstallStateTestCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -AuthenticationType $AuthenticationType `
                    -KeyBasedRenewal:$KeyBasedRenewal

                $result | Should -BeTrue
            }

            Should -Invoke -CommandName Get-WebApplication -Exactly -Times 1
        }

    }

    Context 'When matching Enrollment Policy Web Service is not installed' {
        BeforeEach {
            Mock `
                -CommandName Get-WebApplication `
                -MockWith $mockAdcsEnrollmentPolicyWebServiceInstallStateNoneInstalled
        }

        It 'Given AuthenticationType <AuthenticationType> and KeyBasedRenewal <KeyBasedRenewal> it should return $false' -ForEach $testAdcsEnrollmentPolicyWebServiceInstallStateTestCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $result = Test-AdcsEnrollmentPolicyWebServiceInstallState `
                    -AuthenticationType $AuthenticationType `
                    -KeyBasedRenewal:$KeyBasedRenewal

                $result | Should -BeFalse
            }

            Should -Invoke -CommandName Get-WebApplication -Exactly -Times 1
        }
    }
}

Describe 'DSC_AdcsEnrollmentPolicyWebService\Test-Thumbprint' -Tag 'Private' {
    Context 'When FIPS not set' {
        Context 'When a single valid thumbrpint by parameter is passed' {
            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-Thumbprint -Thumbprint $validThumbprint
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeTrue
                }
            }
        }

        Context 'When a single invalid thumbprint by parameter is passed' {
            It 'Should throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { Test-Thumbprint -Thumbprint $invalidThumbprint } | Should -Throw
                }
            }
        }

        Context 'When a single invalid thumbprint by parameter with -Quiet is passed' {
            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-Thumbprint $invalidThumbprint -Quiet
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeFalse
                }
            }
        }

        Context 'When a single valid thumbprint by pipeline is passed' {
            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = $validThumbprint | Test-Thumbprint
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeTrue
                }
            }
        }

        Context 'When a single invalid thumbprint by pipeline is passed' {
            It 'Should throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { $invalidThumbprint | Test-Thumbprint } | Should -Throw
                }
            }
        }

        Context 'When a single invalid thumbprint by pipeline with -Quiet is passed' {
            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = $invalidThumbprint | Test-Thumbprint -Quiet
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeFalse
                }
            }
        }
    }

    Context 'When FIPS is enabled' {
        BeforeAll {
            Mock -CommandName Get-ItemProperty -MockWith { @{ Enabled = 1 } }
        }

        Context 'When a single valid FIPS thumbrpint by parameter is passed' {
            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-Thumbprint -Thumbprint $validFipsThumbprint
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeTrue
                }
            }
        }

        Context 'When a single invalid FIPS thumbprint by parameter is passed' {
            It 'Should throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { Test-Thumbprint -Thumbprint $validThumbprint } | Should -Throw
                }
            }
        }

        Context 'When a single invalid FIPS thumbprint by parameter with -Quiet is passed' {
            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-Thumbprint $validThumbprint -Quiet
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeFalse
                }
            }
        }

        Context 'When a single valid FIPS thumbprint by pipeline is passed' {
            It 'Should return true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = $validFipsThumbprint | Test-Thumbprint
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeTrue
                }
            }
        }

        Context 'When a single invalid FIPS thumbprint by pipeline is passed' {
            It 'Should throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { $validThumbprint | Test-Thumbprint } | Should -Throw
                }
            }
        }

        Context 'When a single invalid FIPS thumbprint by pipeline with -Quiet is passed' {
            It 'Should return false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = $validThumbprint | Test-Thumbprint -Quiet
                    $result | Should -BeOfType [System.Boolean]
                    $result | Should -BeFalse
                }
            }
        }
    }
}
