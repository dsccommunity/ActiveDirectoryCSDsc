<#
    .SYNOPSIS
        A DSC configuration script to remove desired OCSP URI path extensions for a Certificate Authority.
        No previously configured OCSP URI paths will be removed.
#>

configuration Example
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsOcspExtension RemoveOcspUriPath
        {
            IsSingleInstance = 'Yes'
            OcspUriPath      = @(
                'http://primary-ocsp-responder/ocsp'
                'http://secondary-ocsp-responder/ocsp'
                'http://tertiary-ocsp-responder/ocsp'
            )
            RestartService   = $true
            Ensure           = 'Absent'
        }
    }
}
