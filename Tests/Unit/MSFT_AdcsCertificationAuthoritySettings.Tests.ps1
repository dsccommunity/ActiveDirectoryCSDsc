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

$script:parameterList = Import-LocalizedData `
    -BaseDirectory (Join-Path -Path $script:moduleRoot -ChildPath 'DscResources\MSFT_AdcsCertificationAuthoritySettings') `
    -FileName 'MSFT_AdcsCertificationAuthoritySettings.data.psd1'

try
{
    InModuleScope $script:DSCResourceName {
        # Create the Mock Objects that will be used for running tests
        $script:certificateAuthorityActiveName = 'CONTOSO-CA'
        $script:certificateAuthorityRegistrySettingsActivePath = Join-Path `
            -Path $script:certificateAuthorityRegistrySettingsPath `
            -ChildPath $script:certificateAuthorityActiveName

        # Assemble test mocks and parameter splats
        $script:baseParameterCurrentList = @{}
        $script:baseParameterMockedList = @{}

        foreach ($parameter in $script:parameterList.GetEnumerator())
        {
            $script:baseParameterCurrentList += @{
                $parameter.Name = $parameter.Value.CurrentValue
            }

            $script:baseParameterMockedList += @{
                $parameter.Name = $parameter.Value.MockedValue
            }
        }

        $script:getTargetResourceParameters = @{
            IsSingleInstance = 'Yes'
            Verbose          = $True
        }

        $script:testAndSetTargetResourceParameters = @{
            IsSingleInstance = 'Yes'
            Verbose          = $True
        } + $script:baseParameterCurrentList

        $getItemPropertyValueExistsMock = {
            $script:certificateAuthorityActiveName
        }

        $getItemPropertyValueExistsParameterFilter = {
            $Path -eq $script:certificateAuthorityRegistrySettingsPath -and `
                $Name -eq 'Active'
        }

        $getItemPropertyParameterFilter = {
            $Path -eq $script:certificateAuthorityRegistrySettingsActivePath
        }

        $getItemPropertyMock = {
            return $script:baseParameterMockedList
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
                    foreach ($parameter in $script:parameterList.GetEnumerator())
                    {
                        $script:getTargetResourceResult.$($parameter.Name) | Should -Be $parameter.Value.CurrentValue
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
            Context 'When all Active Directory Certification Authority settings are in the correct state' {
                BeforeAll {
                    Mock -CommandName Get-ItemPropertyValue `
                        -MockWith $getItemPropertyValueExistsMock

                    Mock -CommandName Get-ItemProperty `
                        -MockWith $getItemPropertyMock

                    Mock -CommandName Set-CertificateAuthoritySetting
                }

                It 'Should not throw exception' {
                    {
                        Set-TargetResource @script:testAndSetTargetResourceParameters
                    } | Should -Not -Throw
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

                    Assert-MockCalled `
                        -CommandName Set-CertificateAuthoritySetting `
                        -Exactly -Times 0
                }
            }

            foreach ($parameter in $script:parameterList.GetEnumerator())
            {
                Context ('When all Active Directory Certification Authority settings are in the correct state except {0}' -f $parameter.Name) {
                    BeforeAll {
                        Mock -CommandName Get-ItemPropertyValue `
                        -MockWith $getItemPropertyValueExistsMock

                        Mock -CommandName Get-ItemProperty `
                            -MockWith $getItemPropertyMock

                        Mock -CommandName Set-CertificateAuthoritySetting

                        Mock -CommandName Restart-ServiceIfExists
                    }

                    It 'Should not throw exception' {
                        {
                            $setTargetResourceParameters = @{} + $script:testAndSetTargetResourceParameters
                            $setTargetResourceParameters.$($parameter.Name) = $parameter.Value.NewValue
                            Set-TargetResource @setTargetResourceParameters
                        } | Should -Not -Throw
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

                        Assert-MockCalled `
                            -CommandName Set-CertificateAuthoritySetting `
                            -ParameterFilter {
                                $Name -eq $parameter.Name -and `
                                $Value -eq $parameter.Value.SetValue
                            } `
                            -Exactly -Times 1

                        Assert-MockCalled `
                            -CommandName Restart-ServiceIfExists `
                            -Exactly -Times 1
                    }
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
                        $script:setTargetResourceResult = Set-TargetResource @script:testAndSetTargetResourceParameters
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

        Describe 'MSFT_AdcsCertificationAuthoritySettings\Test-TargetResource' {
            Context 'When all Active Directory Certification Authority settings are in the correct state' {
                BeforeAll {
                    Mock -CommandName Get-ItemPropertyValue `
                        -MockWith $getItemPropertyValueExistsMock

                    Mock -CommandName Get-ItemProperty `
                        -MockWith $getItemPropertyMock
                }

                It 'Should not throw exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @script:testAndSetTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should return true' {
                    $testTargetResourceResult | Should -BeTrue
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

            foreach ($parameter in $script:parameterList.GetEnumerator())
            {
                Context "When all Active Directory Certification Authority settings are in the correct state, except $($parameter.Name) is different" {
                    BeforeAll {
                        Mock -CommandName Get-ItemPropertyValue `
                        -MockWith $getItemPropertyValueExistsMock

                        Mock -CommandName Get-ItemProperty `
                            -MockWith $getItemPropertyMock
                    }

                    It 'Should not throw exception' {
                        {
                            $currentTestTargetResourceParameters = @{} + $script:testAndSetTargetResourceParameters
                            $currentTestTargetResourceParameters[$parameter.Name] = $parameter.Value.NewValue
                            $script:testTargetResourceResult = Test-TargetResource @currentTestTargetResourceParameters
                        } | Should -Not -Throw
                    }

                    It 'Should return false' {
                        $testTargetResourceResult | Should -BeFalse
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
            }

            Context 'When Active Directory Certification Authority is not installed' {
                BeforeAll {
                    Mock -CommandName Get-ItemPropertyValue
                }

                $exception = Get-ObjectNotFoundException -Message ($script:localizedData.CertificateAuthorityNoneActive -f `
                    $script:certificateAuthorityRegistrySettingsPath)

                It 'Should throw expected exception' {
                    {
                        $script:testTargetResourceResult = Test-TargetResource @script:testAndSetTargetResourceParameters
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

        Describe 'MSFT_AdcsCertificationAuthoritySettings\Get-CertificateAuthoritySettings' {
            Context 'When Active Directory Certification Authority is installed' {
                BeforeAll {
                    Mock -CommandName Get-ItemPropertyValue `
                        -MockWith $getItemPropertyValueExistsMock

                    Mock -CommandName Get-ItemProperty `
                        -MockWith $getItemPropertyMock
                }

                It 'Should not throw exception' {
                    {
                        $script:getCertificateAuthoritySettingsResult = Get-CertificateAuthoritySettings
                    } | Should -Not -Throw
                }

                It 'Should return Active Directory Certification Authority settings' {
                    foreach ($parameter in $script:parameterList.GetEnumerator())
                    {
                        $script:getCertificateAuthoritySettingsResult.$($parameter.Name) | Should -Be $parameter.Value.MockedValue
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
                        $script:getCertificateAuthoritySettingsResult = Get-CertificateAuthoritySettings
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
