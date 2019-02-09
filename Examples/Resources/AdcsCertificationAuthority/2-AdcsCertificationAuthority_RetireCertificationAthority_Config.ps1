<#PSScriptInfo
.VERSION 1.0.0
.GUID d0e64a0f-c86a-4b7f-b1db-aee24df4b63f
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
        This example will add the retire an Active Directory Certificate Services
        certificate authority from a node and uninstall the Active Directory Certificate
        Services certification authority feature.

        It will set the Root CA common came to 'Contoso Root CA' and the CA distinguished
        name suffix to 'DC=CONTOSO,DC=COM'. If an existing CA root certificate exists
        in the Active Directory then it will be overwritten.
#>
Configuration AdcsCertificationAuthority_RetireCertificationAthority_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -Module ActiveDirectoryCSDsc

    Node localhost
    {
        AdcsCertificationAuthority CertificateAuthority
        {
            IsSingleInstance          = 'Yes'
            Ensure                    = 'Absent'
            Credential                = $Credential
            CAType                    = 'EnterpriseRootCA'
            CACommonName              = 'Contoso Root CA'
            CADistinguishedNameSuffix = 'DC=CONTOSO,DC=COM'
            OverwriteExistingCAinDS   = $True
        }

        WindowsFeature ADCS-Cert-Authority
        {
            Ensure    = 'Absent'
            Name      = 'ADCS-Cert-Authority'
            DependsOn = '[AdcsCertificationAuthority]CertificateAuthority'
        }
    }
}
