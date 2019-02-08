<#
    .SYNOPSIS
        A DSC configuration script to add desired OCSP URI path extensions for a Certificate Authority.
        This will remove all existing OCSP URI paths from the Certificate Authority.
#>

configuration Example
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsOcspExtension AddOcspUriPath
        {
            IsSingleInstance = 'Yes'
            OcspUriPath      = @(
                'http://primary-ocsp-responder/ocsp'
                'http://secondary-ocsp-responder/ocsp'
                'http://tertiary-ocsp-responder/ocsp'
            )
            RestartService   = $true
            Ensure           = 'Present'
        }
    }
}
