@{
    # Version number of this module.
    moduleVersion = '4.0.0.0'

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
    PowerShellVersion = '5.0'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # DSC resources to export from this module
    DscResourcesToExport = @(
        'AdcsAuthorityInformationAccess',
        'AdcsCertificationAuthority',
        'AdcsCertificationAuthoritySettings',
        'AdcsEnrollmentPolicyWebService',
        'AdcsOnlineResponder',
        'AdcsWebEnrollment',
        'AdscTemplate'
        )

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
        ReleaseNotes = '- BREAKING CHANGE: ActiveDirectoryCSDsc module minimum requirements updated
  to WMF 5.0 because newly added AdcsCertificateAuthoritySettings resource
  requires WMF 5.0.
- Added new resource AdcsCertificateAuthoritySettings - see
  [Issue 13](https://github.com/PowerShell/ActiveDirectoryCSDsc/issues/13).
- Added new resource AdcsTemplate.
- Replaced `switch` blocks with `if` blocks for evaluating "Ensure" parameter
  because switch was missing `break` - fixes [Issue 87](https://github.com/PowerShell/ActiveDirectoryCSDsc/issues/87).
- Added Comment Based Help for `New-NotImplementedException` common function.
- Moved code to create the user account for use in integration test into a
  `CommonTestHelper.psm1` function.
- Removed user account creation code from `AppVeyor.yml` and into integration
  tests themselves to make tests execution easier.
- Updated user account creation code to use local user/group management Powershell
  cmdlets available in WMF 5.1 - fixes [Issue 24](https://github.com/PowerShell/ActiveDirectoryCSDsc/issues/24).
- AdcsCertificationAuthority:
  - Integration tests updated to create test user account in administrators
    group to make test execution easier.

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}



