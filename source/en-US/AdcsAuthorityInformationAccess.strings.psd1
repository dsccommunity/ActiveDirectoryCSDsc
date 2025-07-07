<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource AdcsAuthorityInformationAccess module. This file should only contain
        localized strings for private functions, public command, and
        classes (that are not a DSC resource).
#>

ConvertFrom-StringData @'
    ## Strings overrides for the ResourceBase's default strings.
    # None

    ## Strings directly used by the derived class AdcsAuthorityInformationAccess.
    RestartingCertSvcMessage = Active Directory Certificate Authority settings have changed, so 'CertSvc' service is restarting. (ADCSAIA000)
'@
