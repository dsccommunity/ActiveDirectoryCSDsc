<#PSScriptInfo
.VERSION 1.0.0
.GUID a6255023-06d8-420d-9407-b575f079b314
.AUTHOR DSC Community
.COMPANYNAME DSC Community
.COPYRIGHT DSC Community contributors. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/dsccommunity/ActiveDirectoryCSDsc/blob/main/LICENSE
.PROJECTURI https://github.com/dsccommunity/ActiveDirectoryCSDsc
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
        This example will set the Online Responder OCSP URIs
        to be included in the OCSP extension.
#>
configuration AdcsAuthorityInformationAccess_SetOcsp_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAuthorityInformationAccess SetOcsp
        {
            IsSingleInstance    = 'Yes'
            OcspUri             = @(
                'http://primary-ocsp-responder/ocsp'
                'http://secondary-ocsp-responder/ocsp'
                'http://tertiary-ocsp-responder/ocsp'
            )
            AllowRestartService = $true
        }
    }
}
