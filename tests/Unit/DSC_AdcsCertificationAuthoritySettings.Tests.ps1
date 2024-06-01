<#
    .SYNOPSIS
        Unit test for DSC_AdcsCertificationAuthoritySettings DSC resource.

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

    #Test moving test data to Discovery

    $parameterData = Import-LocalizedData `
        -BaseDirectory (Join-Path -Path $PSScriptRoot -ChildPath '..\..\source\DSCResources\DSC_AdcsCertificationAuthoritySettings\')`
        -FileName 'DSC_AdcsCertificationAuthoritySettings.data.psd1'

    # Assemble test mocks and parameter splats
    $script:baseParameterCurrentList = @{ }
    $script:baseParameterMockedList = @{ }
    $script:settingsList = @()

    foreach ($parameter in $parameterData.GetEnumerator())
    {
        $script:baseParameterCurrentList += @{
            $parameter.Name = $parameter.Value.CurrentValue
        }

        $script:baseParameterMockedList += @{
            $parameter.Name = $parameter.Value.MockedValue
        }

        $script:settingsList += @{
            Name         = $parameter.Key;
            CurrentValue = $parameter.Value.CurrentValue;
            NewValue     = $parameter.Value.NewValue;
            MockedValue  = $parameter.Value.MockedValue;
            SetValue     = $parameter.Value.SetValue;
        }
    }
}

BeforeAll {
    $script:dscResourceName = 'DSC_AdcsCertificationAuthoritySettings'
    $script:dscModuleName = 'ActiveDirectoryCSDsc'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName

    # Test Data
    $script:certificateAuthorityActiveName = 'CONTOSO-CA'
    $script:certificateAuthorityRegistrySettingsPath = 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration'

    $script:certificateAuthorityRegistrySettingsActivePath = Join-Path `
        -Path $certificateAuthorityRegistrySettingsPath `
        -ChildPath $certificateAuthorityActiveName

    $script:getItemPropertyValueExistsMock = {
        $script:certificateAuthorityActiveName
    }

    $script:getItemPropertyValueExistsParameterFilter = {
        $Path -eq $certificateAuthorityRegistrySettingsPath -and `
            $Name -eq 'Active'
    }

    $script:getItemPropertyParameterFilter = {
        $Path -eq $certificateAuthorityRegistrySettingsActivePath
    }

    $script:getItemPropertyMock = {
        return $baseParameterMockedList
    }
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe 'DSC_AdcsCertificationAuthoritySettings\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            $script:getTargetResourceParameters = @{
                IsSingleInstance = 'Yes'
            }
        }
    }

    Context 'When Active Directory Certification Authority is installed' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue `
                -MockWith $getItemPropertyValueExistsMock

            Mock -CommandName Get-ItemProperty `
                -MockWith $getItemPropertyMock
        }

        It 'Should not throw exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                } | Should -Not -Throw

            }
        }

        It 'Should return correct Active Directory Certification Authority setting <Name>' -ForEach $settingsList {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult.$($Name) | Should -Be $CurrentValue
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Get-ItemProperty `
                -ParameterFilter $getItemPropertyParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When Active Directory Certification Authority is not installed' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue
        }

        It 'Should throw expected exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $exception = Get-ObjectNotFoundException -Message ($script:localizedData.CertificateAuthorityNoneActive -f `
                        $script:certificateAuthorityRegistrySettingsPath)
                { Get-TargetResource @script:getTargetResourceParameters } | Should -Throw $exception
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsCertificationAuthoritySettings\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        InModuleScope -Parameters @{
            baseTestParameters = $baseParameterCurrentList
        } -ScriptBlock {

            $script:setTargetResourceParameters = @{
                IsSingleInstance = 'Yes'
            } + $baseTestParameters
        }
    }

    Context 'When all Active Directory Certification Authority settings are in the correct state' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue `
                -MockWith $getItemPropertyValueExistsMock

            Mock -CommandName Get-ItemProperty `
                -MockWith $getItemPropertyMock

            Mock -CommandName Set-CertificateAuthoritySetting
        }

        It 'Should not throw exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    Set-TargetResource @setTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Get-ItemProperty `
                -ParameterFilter $getItemPropertyParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Set-CertificateAuthoritySetting `
                -Exactly -Times 0 -Scope Context
        }
    }

    Context 'When all Active Directory Certification Authority settings are in the correct state except <Name>' -ForEach $settingsList {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue `
                -MockWith $getItemPropertyValueExistsMock

            Mock -CommandName Get-ItemProperty `
                -MockWith $getItemPropertyMock

            Mock -CommandName Set-CertificateAuthoritySetting

            Mock -CommandName Restart-ServiceIfExists
        }

        It 'Should not throw exception' {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $currentSetTargetResourceParameters = @{ } + $setTargetResourceParameters
                    $currentSetTargetResourceParameters.$($Name) = $NewValue
                    Set-TargetResource @currentSetTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Get-ItemProperty `
                -ParameterFilter $getItemPropertyParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Set-CertificateAuthoritySetting `
                -ParameterFilter {
                $Name -eq $Name -and `
                    $Value -eq $SetValue
            } `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Restart-ServiceIfExists `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When Active Directory Certification Authority is not installed' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue
        }

        It 'Should throw expected exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $exception = Get-ObjectNotFoundException -Message ($script:localizedData.CertificateAuthorityNoneActive -f `
                        $script:certificateAuthorityRegistrySettingsPath)

                {
                    Set-TargetResource @script:setTargetResourceParameters
                } | Should -Throw $exception
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsCertificationAuthoritySettings\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        InModuleScope -Parameters @{
            baseTestParameters = $baseParameterCurrentList
        } -ScriptBlock {

            $script:testTargetResourceParameters = @{
                IsSingleInstance = 'Yes'
            } + $baseTestParameters
        }
    }

    Context 'When all Active Directory Certification Authority settings are in the correct state' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue `
                -MockWith $getItemPropertyValueExistsMock

            Mock -CommandName Get-ItemProperty `
                -MockWith $getItemPropertyMock
        }

        It 'Should not throw exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeTrue
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Get-ItemProperty `
                -ParameterFilter $getItemPropertyParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }


    Context 'When all Active Directory Certification Authority settings are in the correct state, except <Name> is different' -ForEach $settingsList {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue `
                -MockWith $getItemPropertyValueExistsMock

            Mock -CommandName Get-ItemProperty `
                -MockWith $getItemPropertyMock
        }

        It 'Should not throw exception' {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $currentTestTargetResourceParameters = @{ } + $testTargetResourceParameters
                    $currentTestTargetResourceParameters[$Name] = $NewValue
                    $script:testTargetResourceResult = Test-TargetResource @currentTestTargetResourceParameters
                } | Should -Not -Throw
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceResult | Should -BeFalse
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Get-ItemProperty `
                -ParameterFilter $getItemPropertyParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }


    Context 'When Active Directory Certification Authority is not installed' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue
        }

        It 'Should throw expected exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $exception = Get-ObjectNotFoundException -Message ($script:localizedData.CertificateAuthorityNoneActive -f `
                        $script:certificateAuthorityRegistrySettingsPath)

                {
                    Test-TargetResource @testTargetResourceParameters
                } | Should -Throw $exception
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsCertificationAuthoritySettings\Get-CertificateAuthoritySettings' -Tag 'Private' {
    Context 'When Active Directory Certification Authority is installed' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue `
                -MockWith $getItemPropertyValueExistsMock

            Mock -CommandName Get-ItemProperty `
                -MockWith $getItemPropertyMock
        }

        It 'Should not throw exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:getCertificateAuthoritySettingsResult = Get-CertificateAuthoritySettings
                } | Should -Not -Throw
            }
        }

        It 'Should return Active Directory Certification Authority settings <Name>' -ForEach $settingsList {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getCertificateAuthoritySettingsResult.$($Name) | Should -Be $MockedValue
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context

            Should -Invoke `
                -CommandName Get-ItemProperty `
                -ParameterFilter $getItemPropertyParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }

    Context 'When Active Directory Certification Authority is not installed' {
        BeforeAll {
            Mock -CommandName Get-ItemPropertyValue
        }

        It 'Should throw expected exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $exception = Get-ObjectNotFoundException -Message ($script:localizedData.CertificateAuthorityNoneActive -f `
                        $script:certificateAuthorityRegistrySettingsPath)

                { Get-CertificateAuthoritySettings } | Should -Throw $exception
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke `
                -CommandName Get-ItemPropertyValue `
                -ParameterFilter $getItemPropertyValueExistsParameterFilter `
                -Exactly -Times 1 -Scope Context
        }
    }
}

Describe 'DSC_AdcsCertificationAuthoritySettings\Convert-AuditFilterToStringArray' -Tag 'Private' {
    Context 'When the AuditFilter is 0' {
        It 'Should return null' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                Convert-AuditFilterToStringArray -AuditFilter 0 | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the AuditFilter is 3' {
        It 'Should return StartAndStopADCS and BackupAndRestoreCADatabase' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Convert-AuditFilterToStringArray -AuditFilter 3 | Should -Be @(
                    'StartAndStopADCS'
                    'BackupAndRestoreCADatabase'
                )
            }
        }
    }

    Context 'When the AuditFilter is 127' {
        It 'Should return all audit filters' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

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
}

Describe 'DSC_AdcsCertificationAuthoritySettings\Convert-StringArrayToAuditFilter' -Tag 'Private' {
    Context 'When the string array is empty' {
        It 'Should return 0' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Convert-StringArrayToAuditFilter -StringArray @() | Should -BeExactly 0
            }
        }
    }

    Context 'When the string array contains StartAndStopADCS and BackupAndRestoreCADatabase' {
        It 'Should return 3' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Convert-StringArrayToAuditFilter -StringArray @('StartAndStopADCS', 'BackupAndRestoreCADatabase') | Should -BeExactly 3
            }
        }
    }

    Context 'When the string array contains all audit filter values' {
        It 'Should return 127' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

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
