@{
    # Version number of this module.
    moduleVersion = '4.1.0.0'

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
        'AdcsCertificationAuthority',
        'AdcsCertificationAuthoritySettings'
        'AdcsEnrollmentPolicyWebService',
        'AdcsOnlineResponder',
        'AdcsWebEnrollment',
        'AdcsOcspExtension',
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
        ReleaseNotes = '- AdcsCertificationAuthoritySettings:
  - Fix grammar in the resource README.md.
- Fix minor style issues in statement case.

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}




