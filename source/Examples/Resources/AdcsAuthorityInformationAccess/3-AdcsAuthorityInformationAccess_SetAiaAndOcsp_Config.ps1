<#PSScriptInfo
.VERSION 1.0.0
.GUID 7469f3d7-a801-49cc-877a-97d47f12603e
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
        This example will set the Authority Information Access and Online Responder
        OCSP URIs to be included in the AIA and OCSP extensions respectively.
#>
configuration AdcsAuthorityInformationAccess_SetAiaAndOcsp_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAuthorityInformationAccess SetAiaAndOcsp
        {
            IsSingleInstance    = 'Yes'
            AiaUri              = @(
                'http://setAIATest1/Certs/<CATruncatedName>.cer'
                'http://setAIATest2/Certs/<CATruncatedName>.cer'
                'http://setAIATest3/Certs/<CATruncatedName>.cer'
                'file://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CAName><CertificateName>.crt'
            )
            OcspUri             = @(
                'http://primary-ocsp-responder/ocsp'
                'http://secondary-ocsp-responder/ocsp'
                'http://tertiary-ocsp-responder/ocsp'
            )
            AllowRestartService = $true
        }
    }
}
