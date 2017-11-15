@{
    # Version number of this module.
    ModuleVersion = '1.3.0.0'

    # ID used to uniquely identify this module
    GUID              = 'f8ddd7fc-c6d6-469e-8a80-c96efabe2fcc'

    # Author of this module
    Author            = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName       = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright         = '(c) 2017 Microsoft Corporation. All rights reserved.'

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
            LicenseUri   = 'https://github.com/PowerShell/xAdcsDeployment/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/PowerShell/xAdcsDeployment'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
        ReleaseNotes = '- Updated to meet HQRM guidelines - fixes
  [issue 33](https://github.com/PowerShell/xAdcsDeployment/issues/33).
- Fixed markdown rule violations in README.MD.
- Change examples to meet HQRM standards and optin to Example validation
  tests.
- Replaced examples in README.MD to links to Example files.
- Added the VS Code PowerShell extension formatting settings that cause PowerShell
  files to be formatted as per the DSC Resource kit style guidelines.
- Opted into Common Tests "Validate Module Files" and "Validate Script Files".
- Corrected description in manifest.
- Added .github support files:
  - CONTRIBUTING.md
  - ISSUE_TEMPLATE.md
  - PULL_REQUEST_TEMPLATE.md
- Resolved all PSScriptAnalyzer warnings and style guide warnings.
- Converted all tests to meet Pester V4 guidelines - fixes
  [issue 32](https://github.com/PowerShell/xAdcsDeployment/issues/32).
- Fixed spelling mistakes in README.MD.
- Fix to ensure exception thrown if failed to install or uninstall service - fixes
  [issue 3](https://github.com/PowerShell/xAdcsDeployment/issues/3).
- Converted AppVeyor.yml to use shared AppVeyor module in DSCResource.Tests - fixes
  [issue 29](https://github.com/PowerShell/xAdcsDeployment/issues/29).

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}

