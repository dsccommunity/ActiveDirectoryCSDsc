<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource AdcsAuthorityInformationAccess.
#>

ConvertFrom-StringData @'
    ## Strings overrides for the ResourceBase's default strings.
    # None

    ## Strings directly used by the derived class AdcsAuthorityInformationAccess.
    AddingAdcsAiaUriMessage = Adding '{0}' URI '{1}'. (ADCSAIA0001)
    RemovingAdcsAiaUriMessage = Removing '{0}' URI '{1}'. (ADCSAIA0002)
    RestartingCertSvcMessage = Active Directory Certificate Authority settings have changed, so 'CertSvc' service is restarting. (ADCSAIA0003)
'@
