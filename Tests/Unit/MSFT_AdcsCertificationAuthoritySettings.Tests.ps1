$script:DSCModuleName = 'ActiveDirectoryCSDsc'
$script:DSCResourceName = 'MSFT_AdcsCertificationAuthoritySettings'

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
    InModuleScope $script:DSCResourceName {
        # Create the Mock Objects that will be used for running tests
        $script:parameterList = @{
            CACertPublicationURLs = @{
                Type         = 'String[]'
                CurrentValue = @('1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt', '2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11')
                NewValue     = @('1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt', '2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt')
                MockedValue  = "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt`n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11"
            }
            CRLPublicationURLs    = @{
                Type         = 'String[]'
                CurrentValue = @('65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl', '79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10')
                NewValue     = @('65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl', '6:http://pki.contoso.com/CertEnroll/%3%8%9.crl')
                MockedValue  = "65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl`n79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10"
            }
            CRLOverlapUnits       = @{
                Type         = 'Uint32'
                CurrentValue = 24
                NewValue     = 12
                MockedValue  = 24
            }
            CRLOverlapPeriod      = @{
                Type         = 'String'
                CurrentValue = 'Hours'
                NewValue     = 'Days'
                MockedValue  = 'Hours'
            }
            CRLPeriodUnits        = @{
                Type         = 'Uint32'
                CurrentValue = 5
                NewValue     = 10
                MockedValue  = 5
            }
            CRLPeriod             = @{
                Type         = 'String'
                CurrentValue = 'Years'
                NewValue     = 'Months'
                MockedValue  = 'Years'
            }
            ValidityPeriodUnits   = @{
                Type         = 'Uint32'
                CurrentValue = 2
                NewValue     = 4
                MockedValue  = 2
            }
            ValidityPeriod        = @{
                Type         = 'String'
                CurrentValue = 'Days'
                NewValue     = 'Hours'
                MockedValue  = 'Days'
            }
            DSConfigDN            = @{
                Type         = 'String'
                CurrentValue = 'CN=Configuration,DC=CONTOSO,DC=COM'
                NewValue     = 'CN=Configuration,DC=SOMEWHERE,DC=COM'
                MockedValue  = 'CN=Configuration,DC=CONTOSO,DC=COM'
            }
            DSDomainDN            = @{
                Type         = 'String'
                CurrentValue = 'DC=CONTOSO,DC=COM'
                NewValue     = 'DC=SOMEWHERE,DC=COM'
                MockedValue  = 'DC=CONTOSO,DC=COM'
            }
            AuditFilter           = @{
                Type         = 'String[]'
                CurrentValue = @('StartAndStopADCS', 'ChangeCAConfiguration')
                NewValue     = @('BackupAndRestoreCADatabase', 'ChangeCAConfiguration')
                MockedValue  = 65
            }
        }
        $script:certificateAuthorityActiveName = 'CONTOSO-CA'
        $script:certificateAuthorityRegistrySettingsActivePath = Join-Path `
            -Path $script:certificateAuthorityRegistrySettingsPath `
            -ChildPath $script:certificateAuthorityActiveName
        $script:getTargetResourceParameters = @{
            IsSingleInstance = 'Yes'
            Verbose          = $True
        }
        $script:testTargetResourceParameters = @{
            IsSingleInstance = 'Yes'
            Verbose          = $True
        }
        foreach ($parameter in $script:parameterList.GetEnumerator())
        {
            $script:testTargetResourceParameters += @{
                $parameter.Name = $parameter.Value.CurrentValue
            }
        }

        $getItemPropertyValueExistsMock = {
            $script:certificateAuthorityActiveName
            }
        $getItemPropertyValueExistsParameterFilter = {
            $Path -eq $script:certificateAuthorityRegistrySettingsPath -and `
                $Name -eq 'Active'
        }
        $getItemPropertyMock = {
            $parameters = @{ }

            foreach ($parameter in $script:parameterList.GetEnumerator())
            {
                $parameters += @{
                    $parameter.Name = $parameter.Value.MockedValue
                }
            }

            return $parameters
        }
        $getItemPropertyParameterFilter = {
            $Path -eq $script:certificateAuthorityRegistrySettingsActivePath
        }

        $getTargetResourceInStateMock = {
            $parameters = @{ }

            foreach ($parameter in $script:parameterList.GetEnumerator())
            {
                $parameters += @{
                    $parameter.Name = $parameter.Value.CurrentValue
                }
            }

            return $parameters
        }

        Describe 'MSFT_AdcsCertificationAuthoritySettings\Get-TargetResource' {
            Context 'When Active Directory Certification Authority is installed' {
                BeforeAll {
                    Mock -CommandName Get-ItemPropertyValue `
                        -MockWith $getItemPropertyValueExistsMock

                    Mock -CommandName Get-ItemProperty `
                        -MockWith $getItemPropertyMock
                }

                It 'Should not throw exception' {
                    {
                        $script:getTargetResourceResult = Get-TargetResource @script:getTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return Active Directory Certification Authority settings' {
                    foreach ($parameter in $script:parameterList)
                    {
                        $script:getTargetResourceResult.$($parameter.Name) | Should -Be $parameter.CurrentValue
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled `
                        -CommandName Get-ItemPropertyValue `
                        -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                        -Exactly -Times 1

                    Assert-MockCalled `
                        -CommandName Get-ItemProperty `
                        -ParameterFilter $getItemPropertyParameterFilter `
                        -Exactly -Times 1
                }
            }

            Context 'When Active Directory Certification Authority is not installed' {
                BeforeAll {
                    Mock -CommandName Get-ItemPropertyValue
                }

                $exception = Get-ObjectNotFoundException -Message ($script:localizedData.CertificateAuthorityNoneActive -f `
                    $script:certificateAuthorityRegistrySettingsPath)

                It 'Should throw expected exception' {
                    {
                        $script:getTargetResourceResult = Get-TargetResource @script:getTargetResourceParameters
                    } | Should -Throw $exception
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled `
                        -CommandName Get-ItemPropertyValue `
                        -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                        -Exactly -Times 1
                }
            }
        }

        Describe 'MSFT_AdcsCertificationAuthoritySettings\Set-TargetResource' {
        }

        Describe 'MSFT_AdcsCertificationAuthoritySettings\Test-TargetResource' {
            Context 'When all Active Directory Certification Authority settings are in the correct state' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource `
                        -MockWith $getTargetResourceInStateMock
                }

                It 'Should not throw exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @script:testTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return true' {
                    $testTargetResourceResult | Should -BeTrue
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled `
                        -CommandName Get-TargetResource `
                        -Exactly -Times 1
                }
            }

            foreach ($parameter in $script:parameterList)
            {
                Context "When all Active Directory Certification Authority settings are in the correct state, except $($parameter.Name) is different" {
                    It 'Should return false' {
                        $testTargetResourceSplat = $adcsCertificationAuthorityParameters.Clone()
                        $testTargetResourceSplat.$($parameter.Name) = $parameter.NewValue
                        Test-TargetResource @testTargetResourceSplat | Should -Be $False
                    }

                    It 'Should call expected Mocks' {
                        foreach ($parameter in $parameterList)
                        {
                            $parameterPath = Join-Path `
                                -Path 'WSMan:\Localhost\Service\' `
                                -ChildPath $parameter.Path

                            Assert-MockCalled `
                                -CommandName Get-Item `
                                -ParameterFilter {
                                $Path -eq $parameterPath
                            } -Exactly -Times 1
                        }
                    }
                }
            }
        }

        Describe 'MSFT_AdcsCertificationAuthoritySettings\Convert-AuditFilterToStringArray' {
            Context 'When the AuditFilter is 0' {
                It 'Should return null' {
                    Convert-AuditFilterToStringArray -AuditFilter 0 | Should -BeNullOrEmpty
                }
            }

            Context 'When the AuditFilter is 3' {
                It 'Should return StartAndStopADCS and BackupAndRestoreCADatabase' {
                    Convert-AuditFilterToStringArray -AuditFilter 3 | Should -Be @(
                        'StartAndStopADCS'
                        'BackupAndRestoreCADatabase'
                    )
                }
            }

            Context 'When the AuditFilter is 127' {
                It 'Should return all audit filters' {
                    Convert-AuditFilterToStringArray -AuditFilter 127 | Should -Be @(
                        'StartAndStopADCS'
                        'BackupAndRestoreCADatabase'
                        'IssueAndManageCertificateRequests'
                        'RevokeCertificatesAndPublishCRLs'
                        'ChangeCASecuritySettings'
                        'StoreAndRetrieveArchivedKeys'
                        'ChangeCAConfiguration'
                    )
                }
            }
        }

        Describe 'MSFT_AdcsCertificationAuthoritySettings\Convert-StringArrayToAuditFilter' {
            Context 'When the string array is empty' {
                It 'Should return 0' {
                    Convert-StringArrayToAuditFilter -StringArray @() | Should -BeExactly 0
                }
            }

            Context 'When the string array contains StartAndStopADCS and BackupAndRestoreCADatabase' {
                It 'Should return 3' {
                    Convert-StringArrayToAuditFilter -StringArray @('StartAndStopADCS', 'BackupAndRestoreCADatabase') | Should -BeExactly 3
                }
            }

            Context 'When the string array contains all audit filter values' {
                It 'Should return 127' {
                    Convert-StringArrayToAuditFilter -StringArray @(
                        'StartAndStopADCS'
                        'BackupAndRestoreCADatabase'
                        'IssueAndManageCertificateRequests'
                        'RevokeCertificatesAndPublishCRLs'
                        'ChangeCASecuritySettings'
                        'StoreAndRetrieveArchivedKeys'
                        'ChangeCAConfiguration'
                    ) | Should -BeExactly 127
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
