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
        A DSC configuration script to add desired AIA URI path extensions for a Certificate Authority.
        This will remove all existing AIA URI paths from the Certificate Authority.
#>
configuration AdcsAiaExtension_AddAiaPath_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAiaExtension AddAiaUriPath
        {
            IsSingleInstance = 'Yes'
            AiaUriPath      = @(
                'http://primary-aia-responder/aia'
                'http://secondary-aia-responder/aia'
                'http://tertiary-aia-responder/aia'
            )
            RestartService   = $true
            Ensure           = 'Present'
        }
    }
}
