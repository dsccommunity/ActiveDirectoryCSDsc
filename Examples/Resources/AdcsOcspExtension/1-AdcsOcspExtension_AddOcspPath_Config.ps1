<#PSScriptInfo
.VERSION 1.0.0
.GUID 93c71497-c4ac-452e-baf1-aff17bd4ecac
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/ActiveDirectoryCSDsc/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/ActiveDirectoryCSDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module ActiveDirectoryCSDsc

<#
    .DESCRIPTION
        A DSC configuration script to add desired OCSP URI path extensions for a Certificate Authority.
        This will remove all existing OCSP URI paths from the Certificate Authority.
#>
configuration AdcsOcspExtension_AddOcspPath_Config
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
