$script:DSCModuleName   = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsCertificationAuthority'

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

try
{
    InModuleScope $($script:DSCResourceName) {
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

        $dummyCredential = New-Object System.Management.Automation.PSCredential ("Administrator",(New-Object -Type SecureString))

        $testParametersPresent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            CAType           = 'StandaloneRootCA'
            Credential       = $dummyCredential
            Verbose          = $true
        }

        $testParametersAbsent = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Absent'
            CAType           = 'StandaloneRootCA'
            Credential       = $dummyCredential
            Verbose          = $true
        }

        function Install-AdcsCertificationAuthority {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $True)]
                [ValidateSet('EnterpriseRootCA','EnterpriseSubordinateCA','StandaloneRootCA','StandaloneSubordinateCA')]
                [System.String]
                $CAType,

                [Parameter(Mandatory = $True)]
                [System.Management.Automation.PSCredential]
                $Credential,

                [Parameter()]
                [System.String]
                $CACommonName,

                [Parameter()]
                [System.String]
                $CADistinguishedNameSuffix,

                [Parameter()]
                [System.String]
                $CertFile,

                [Parameter()]
                [System.Management.Automation.PSCredential]
                $CertFilePassword,

                [Parameter()]
                [System.String]
                $CertificateID,

                [Parameter()]
                [System.String]
                $CryptoProviderName,

                [Parameter()]
                [System.String]
                $DatabaseDirectory,

                [Parameter()]
                [System.String]
                $HashAlgorithmName,

                [Parameter()]
                [System.Boolean]
                $IgnoreUnicode,

                [Parameter()]
                [System.String]
                $KeyContainerName,

                [Parameter()]
                [System.UInt32]
                $KeyLength,

                [Parameter()]
                [System.String]
                $LogDirectory,

                [Parameter()]
                [System.String]
                $OutputCertRequestFile,

                [Parameter()]
                [System.Boolean]
                $OverwriteExistingCAinDS,

                [Parameter()]
                [System.Boolean]
                $OverwriteExistingDatabase,

                [Parameter()]
                [System.Boolean]
                $OverwriteExistingKey,

                [Parameter()]
                [System.String]
                $ParentCA,

                [Parameter()]
                [ValidateSet('Hours','Days','Months','Years')]
                [System.String]
                $ValidityPeriod,

                [Parameter()]
                [System.UInt32]
                $ValidityPeriodUnits,

                [Parameter()]
                [Switch]
                $Force,

                [Parameter()]
                [Switch]
                $WhatIf
            )
        }

        function Uninstall-AdcsCertificationAuthority {
            [CmdletBinding()]
            param
            (
                [Parameter()]
                [Switch]
                $Force
            )
        }

        Describe 'MSFT_AdcsCertificationAuthority\Get-TargetResource' {
            Context 'When the CA is installed' {
                Mock `
                    -CommandName Install-AdcsCertificationAuthority `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException') } `
                    -Verifiable

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Present' {
                    $result.Ensure  | Should -Be 'Present'
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock

                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the CA is not installed' {
                Mock -CommandName Install-AdcsCertificationAuthority

                $result = Get-TargetResource @testParametersPresent

                It 'Should return Ensure set to Absent' {
                    $result.Ensure  | Should -Be 'Absent'
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'MSFT_AdcsCertificationAuthority\Set-TargetResource' {
            Context 'When theCA is not installed but should be' {
                Mock -CommandName Install-AdcsCertificationAuthority
                Mock -CommandName Uninstall-AdcsCertificationAuthority

                It 'Should not throw an exception' {
                    { Set-TargetResource @testParametersPresent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When the CA is not installed but should be but an error is thrown installing it' {
                Mock `
                    -CommandName Install-AdcsCertificationAuthority `
                    -MockWith { [PSObject] @{ErrorString = 'Something went wrong' }}

                Mock -CommandName Uninstall-AdcsCertificationAuthority

                It 'Should throw exception' {
                    $errorRecord = Get-InvalidOperationRecord -Message 'Something went wrong'

                    { Set-TargetResource @testParametersPresent } | Should Throw $errorRecord
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 0
                }
            }

            Context 'When CA is multi tier and error should not throw for ErrorString with specific text' {
                Mock `
                    -CommandName Install-AdcsCertificationAuthority `
                    -MockWith { [PSObject] @{ ErrorString = 'The Active Directory Certificate Services installation is incomplete' }}

                It 'Should not throw exception' {

                    { Set-TargetResource @testParametersPresent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When CA is multi tier and error should not throw for Error ID 398' {
                Mock `
                    -CommandName Install-AdcsCertificationAuthority `
                    -MockWith { [PSObject] @{
                        ErrorID     = 398
                        ErrorString = 'Something went wrong'
                    }}

                It 'Should not throw exception' {

                    { Set-TargetResource @testParametersPresent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the CA is installed but should not be' {
                Mock -CommandName Install-AdcsCertificationAuthority
                Mock -CommandName Uninstall-AdcsCertificationAuthority

                It 'Should not throw an exception' {
                    { Set-TargetResource @testParametersAbsent } | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 0

                    Assert-MockCalled `
                        -CommandName Uninstall-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }
        }

        Describe 'MSFT_AdcsCertificationAuthority\Test-TargetResource' {
            Context 'When the CA is installed and should be' {
                Mock -CommandName Install-AdcsCertificationAuthority `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException') } `
                    -Verifiable

                $result = Test-TargetResource @testParametersPresent

                It 'Should return true' {
                    $result | Should -Be $True
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the CA is installed but should not be' {
                Mock -CommandName Install-AdcsCertificationAuthority `
                    -MockWith { Throw (New-Object -TypeName 'Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException') } `
                    -Verifiable

                $result = Test-TargetResource @testParametersAbsent

                It 'Should return false' {
                    $result | Should -Be $False
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the CA is not installed but should be' {
                Mock -CommandName Install-AdcsCertificationAuthority `
                    -Verifiable

                $result = Test-TargetResource @testParametersPresent

                It 'Should return false' {
                    $result | Should -Be $false
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
                        -Exactly `
                        -Times 1
                }
            }

            Context 'When the CA is not installed and should not be' {
                Mock -CommandName Install-AdcsCertificationAuthority `
                    -Verifiable

                $result = Test-TargetResource @testParametersAbsent

                It 'Should return true' {
                    $result | Should -Be $True
                }

                It 'Should call expected mocks' {
                    Assert-VerifiableMock
                    Assert-MockCalled `
                        -CommandName Install-AdcsCertificationAuthority `
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
