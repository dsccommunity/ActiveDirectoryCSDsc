<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource AdcsOnlineResponder.
#>

ConvertFrom-StringData @'
    ## Strings overrides for the ResourceBase's default strings.
    # None

    ## Strings directly used by the derived class AdcsOnlineResponder.
    ErrorGetCurrentState = GetCurrentState() failed with an unexpected error. (ADCSOR0001)
    ErrorModifyUninstall = Modify() failed with an unexpected error during uninstall. (ADCSOR0002)
    ErrorModifyInstall   = Modify() failed with an unexpected error during install. (ADCSOR0003)
'@
