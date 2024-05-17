<#
    .SYNOPSIS
        Unit test for DSC_AdcsTemplate DSC resource.

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
    $script:dscResourceName = 'DSC_AdcsTemplate'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\AdcsStub.psm1')
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\AdcsAdministrationStub.psm1')


    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName


}


AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    Remove-Module -Name AdcsStub -Force
    Remove-Module -Name AdcsAdministrationStub -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe 'DSC_AdcsTemplate\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        $mockTemplateList = @(
            @{
                Name = 'User'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.1'
            }
            @{
                Name = 'DirectoryEmailReplication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.29'
            }
            @{
                Name = 'DomainControllerAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.28'
            }
            @{
                Name = 'KerberosAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.33'
            }
        )

        $testTemplatePresent = @{
            Name = 'User'
        }

        $testTemplateNotPresent = @{
            Name = 'EFS'
        }

        $mockGetTemplatePresent = @{
            Name   = 'User'
            Ensure = 'Present'
        }

        $mockGetTemplateNotPresent = @{
            Name   = 'EFS'
            Ensure = 'Absent'
        }
    }

    Context 'When the template is installed' {
        BeforeEach {
            Mock -CommandName Get-CATemplate -MockWith { $mockTemplateList }
            $result = Get-TargetResource @testTemplatePresent
        }
        It 'Should return Ensure set to Present' {
            $result.Ensure | Should -Be 'Present'
        }

        It 'Should call expected mocks' {
            Assert-VerifiableMock

            Assert-MockCalled `
                -CommandName Get-CATemplate `
                -Exactly `
                -Times 1
        }
    }

    Context 'When the template is not installed' {
        BeforeEach {
            Mock -CommandName Get-CATemplate -MockWith { $mockTemplateList }
            $result = Get-TargetResource @testTemplateNotPresent
        }

        It 'Should return Ensure set to Absent' {
            $result.Ensure | Should -Be 'Absent'
        }

        It 'Should call expected mocks' {
            Assert-MockCalled `
                -CommandName Get-CATemplate `
                -Exactly `
                -Times 1
        }
    }

    Context 'When Get-CATemplate throws an exception' {
        BeforeEach {
            Mock -CommandName Get-CATemplate -MockWith { throw }
        }

        It 'Should throw the correct error' {
            $errorRecord = Get-InvalidOperationRecord `
                -Message $script:localizedData.InvalidOperationGettingAdcsTemplateMessage
            { Get-TargetResource @testTemplatePresent } | Should -Throw $errorRecord
        }
    }
}

Describe 'DSC_AdcsTemplate\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        $mockTemplateList = @(
            @{
                Name = 'User'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.1'
            }
            @{
                Name = 'DirectoryEmailReplication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.29'
            }
            @{
                Name = 'DomainControllerAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.28'
            }
            @{
                Name = 'KerberosAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.33'
            }
        )

        $testTemplatePresent = @{
            Name = 'User'
        }

        $testTemplateNotPresent = @{
            Name = 'EFS'
        }

        $mockGetTemplatePresent = @{
            Name   = 'User'
            Ensure = 'Present'
        }

        $mockGetTemplateNotPresent = @{
            Name   = 'EFS'
            Ensure = 'Absent'
        }
    }
    Context 'When the template is not added but should be' {
        BeforeEach {
            Mock -CommandName Add-CATemplate
        }

        It 'Should not throw an exception' {
            { Set-TargetResource @testTemplateNotPresent } | Should -Not -Throw
        }

        It 'Should call expected mock' {
            Assert-MockCalled `
                -CommandName Add-CATemplate `
                -ParameterFilter { $Name -eq $testTemplateNotPresent.Name } `
                -Exactly `
                -Times 1
        }

        Context 'When Add-CATemplate throws an exception' {
            BeforeEach {
                Mock -CommandName Add-CATemplate -MockWith { throw }
            }

            It 'Should throw the correct error' {
                $errorRecord = Get-InvalidOperationRecord `
                    -Message ($script:localizedData.InvalidOperationAddingAdcsTemplateMessage -f $testTemplateNotPresent.Name)
                { Set-TargetResource @testTemplateNotPresent } | Should -Throw $errorRecord
            }
        }

        Context 'When the template is added but should not be' {
            BeforeEach {
                Mock -CommandName Remove-CATemplate
            }

            It 'Should not throw an exception' {
                { Set-TargetResource @testTemplatePresent -Ensure 'Absent' } | Should -Not -Throw
            }

            It 'Should call expected mock' {
                Assert-MockCalled `
                    -CommandName Remove-CATemplate `
                    -ParameterFilter { $Name -eq $testTemplatePresent.Name } `
                    -Exactly `
                    -Times 1
            }
        }

        Context 'When Remove-CATemplate throws an exception' {
            BeforeEach {
                Mock -CommandName Remove-CATemplate -MockWith { throw }
            }

            It 'Should throw the correct error' {
                $errorRecord = Get-InvalidOperationRecord `
                    -Message ($script:localizedData.InvalidOperationRemovingAdcsTemplateMessage -f $testTemplatePresent.Name)
                { Set-TargetResource @testTemplatePresent -Ensure 'Absent' } | Should -Throw $errorRecord
            }
        }
    }
}

Describe 'DSC_AdcsTemplate\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        $mockTemplateList = @(
            @{
                Name = 'User'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.1'
            }
            @{
                Name = 'DirectoryEmailReplication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.29'
            }
            @{
                Name = 'DomainControllerAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.28'
            }
            @{
                Name = 'KerberosAuthentication'
                Oid  = '1.3.6.1.4.1.311.21.8.8499410.11380151.15942274.9578998.10586356.49.1.33'
            }
        )

        $testTemplatePresent = @{
            Name = 'User'
        }

        $testTemplateNotPresent = @{
            Name = 'EFS'
        }

        $mockGetTemplatePresent = @{
            Name   = 'User'
            Ensure = 'Present'
        }

        $mockGetTemplateNotPresent = @{
            Name   = 'EFS'
            Ensure = 'Absent'
        }
    }
    Context 'When the template is added and should be' {
        BeforeEach {
            Mock -CommandName Get-TargetResource -MockWith { $mockGetTemplatePresent }
            $result = Test-TargetResource @testTemplatePresent -Ensure 'Present'
        }
        It 'Should return true' {
            $result | Should -BeTrue
        }

        It 'Should call expected mock' {
            Assert-MockCalled `
                -CommandName Get-TargetResource `
                -ParameterFilter { $Name -eq $testTemplatePresent.Name } `
                -Exactly `
                -Times 1
        }
    }

    Context 'When the template is added and should not be' {
        BeforeEach {
            Mock -CommandName Get-TargetResource `
                -MockWith { $mockGetTemplatePresent }

            $result = Test-TargetResource @testTemplatePresent -Ensure 'Absent'
        }

        It 'Should return false' {
            $result | Should -BeFalse
        }

        It 'Should call expected mock' {
            Assert-MockCalled `
                -CommandName Get-TargetResource `
                -ParameterFilter { $Name -eq $testTemplatePresent.Name } `
                -Exactly `
                -Times 1
        }
    }

    Context 'When the template is not added and should be' {
        BeforeEach {
            Mock -CommandName Get-TargetResource `
            -MockWith { $mockGetTemplateNotPresent }
            $result = Test-TargetResource @testTemplateNotPresent -Ensure 'Present'
        }

        It 'Should return false' {
            $result | Should -BeFalse
        }

        It 'Should call expected mock' {
            Assert-MockCalled `
                -CommandName Get-TargetResource `
                -ParameterFilter { $Name -eq $testTemplateNotPresent.Name } `
                -Exactly `
                -Times 1
        }
    }

    Context 'When the template is not added and should not be' {
        BeforeEach{
            Mock -CommandName Get-TargetResource -MockWith { $MockGetTemplateNotPresent }

            $result = Test-TargetResource @testTemplateNotPresent -Ensure 'Absent'
        }

        It 'Should return true' {
            $result | Should -BeTrue
        }

        It 'Should call expected mock' {
            Assert-MockCalled `
                -CommandName Get-TargetResource `
                -ParameterFilter { $Name -eq $testTemplateNotPresent.Name } `
                -Exactly `
                -Times 1
        }
    }
}
