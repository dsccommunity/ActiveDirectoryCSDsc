@{
    # Version number of this module.
    moduleVersion = '3.0.0.0'

    # ID used to uniquely identify this module
    GUID              = 'f8ddd7fc-c6d6-469e-8a80-c96efabe2fcc'

    # Author of this module
    Author            = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName       = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright         = '(c) 2018 Microsoft Corporation. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'This DSC Resource module can be used to install or uninstall Certificate Services components in Windows Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    CmdletsToExport   = '*'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/PowerShell/ActiveDirectoryCSDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/PowerShell/ActiveDirectoryCSDsc'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
        ReleaseNotes = '- Changed `Assert-VerifiableMocks` to be `Assert-VerifiableMock` to meet
  Pester standards.
- Updated license year in LICENSE.MD and module manifest to 2018.
- Removed requirement for Pester maximum version 4.0.8.
- Added new resource EnrollmentPolicyWebService - see
  [issue 43](https://github.com/PowerShell/ActiveDirectoryCSDsc/issues/43).
- BREAKING CHANGE: New Key for AdcsCertificationAuthority, IsSingleInstance - see
  [issue 47](https://github.com/PowerShell/ActiveDirectoryCSDsc/issues/47).
- Added:
  - MSFT_xADCSOnlineResponder resource to install the Online Responder service.
- Corrected filename of MSFT_AdcsCertificationAuthority integration test file.

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}




