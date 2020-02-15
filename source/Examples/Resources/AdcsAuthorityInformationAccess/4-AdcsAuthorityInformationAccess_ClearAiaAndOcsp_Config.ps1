<#PSScriptInfo
.VERSION 1.0.0
.GUID 7469f3d7-a801-49cc-877a-97d47f12603e
.AUTHOR DSC Community
.COMPANYNAME DSC Community
.COPYRIGHT DSC Community contributors. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/dsccommunity/ActiveDirectoryCSDsc/blob/master/LICENSE
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
        This example will clear the Authority Information Access and Online Responder
        OCSP URIs from the AIA and OCSP extensions respectively.
#>
configuration AdcsAuthorityInformationAccess_ClearAiaAndOcsp_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAuthorityInformationAccess ClearAiaAndOcsp
        {
            IsSingleInstance    = 'Yes'
            AiaUri              = @()
            OcspUri             = @()
            AllowRestartService = $true
        }
    }
}
