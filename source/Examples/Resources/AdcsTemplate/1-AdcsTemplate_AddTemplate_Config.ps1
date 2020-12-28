<#PSScriptInfo
.VERSION 1.0.0
.GUID 4c6ccc96-2660-4689-98b4-37eed05fad89
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
        This example will add the KerberosAuthentication CA Template to the server.
#>
Configuration AdcsTemplate_AddTemplate_Config
{
    Import-DscResource -Module ActiveDirectoryCSDsc

    Node localhost
    {
        AdcsTemplate KerberosAuthentication
        {
            Name   = 'KerberosAuthentication'
            Ensure = 'Present'
        }
    }
}
