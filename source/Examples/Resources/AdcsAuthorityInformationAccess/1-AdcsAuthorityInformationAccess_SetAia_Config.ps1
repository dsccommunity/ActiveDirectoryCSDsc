<#PSScriptInfo
.VERSION 1.0.0
.GUID 590fc450-e559-4f65-9d17-a6f9dcdfcb52
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
        This example will set the Authority Information Access URIs
        to be included in the AIA extension.
#>
configuration AdcsAuthorityInformationAccess_SetAia_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAuthorityInformationAccess SetAia
        {
            IsSingleInstance    = 'Yes'
            AiaUri              = @(
                'http://setAIATest1/Certs/<CATruncatedName>.cer'
                'http://setAIATest2/Certs/<CATruncatedName>.cer'
                'http://setAIATest3/Certs/<CATruncatedName>.cer'
                'file://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CAName><CertificateName>.crt'
            )
            AllowRestartService = $true
        }
    }
}
