<#PSScriptInfo
.VERSION 1.0.0
.GUID 95bd5fea-6d07-4c27-bda5-bdaa9bf08437
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
        A DSC configuration script to remove desired AIA URI extensions for a Certificate Authority.
        No previously configured AIA URIs will be removed.
#>
configuration AdcsAiaExtension_RemoveAia_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAiaExtension RemoveAiaUri
        {
            IsSingleInstance = 'Yes'
            AiaUri           = @(
                'http://setAIATest1/Certs/<CATruncatedName>.cer'
                'http://setAIATest2/Certs/<CATruncatedName>.cer'
                'http://setAIATest3/Certs/<CATruncatedName>.cer'
            )
            RestartService   = $true
            Ensure           = 'Absent'
        }
    }
}
