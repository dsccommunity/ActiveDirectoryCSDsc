<#PSScriptInfo
.VERSION 1.0.0
.GUID ad10a5ac-ed50-44d8-a86a-075258a8f78d
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
        This example will add the Active Directory Certificate Services Certificate Authority
        feature to a server and configure it as a certificate authority enterprise root CA.

        It will then set the certificate authority CA certificate publication URLs and
        certificate revocation list URLs. The certificate revocation list overlap period will
        be set to 8 hours and the certificate revocation list period to 1 month. The
        validity period of the certificate authority period will also be set to 10 years.

        The domain services domain and configuration distinguished names will be set to
        the values expected for an enterprise CA.

        The audit filter settings will be configured to record all audit events.

        See this page for more information on these settings:
        https://blogs.technet.microsoft.com/xdot509/2013/03/22/installing-a-two-tier-pki-hierarchy-in-windows-server-2012-wrap-up/
#>
Configuration AdcsCertificationAuthoritySettings_EnterpriseCA_Config
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
        WindowsFeature ADCS-Cert-Authority
        {
            Ensure = 'Present'
            Name   = 'ADCS-Cert-Authority'
        }

        AdcsCertificationAuthority CertificateAuthority
        {
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            Credential       = $Credential
            CAType           = 'EnterpriseRootCA'
            DependsOn        = '[WindowsFeature]ADCS-Cert-Authority'
        }

        AdcsCertificationAuthoritySettings CertificateAuthoritySettings
        {
            IsSingleInstance = 'Yes'
            CACertPublicationURLs = @(
                '1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt'
                '2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11'
                '2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt'
            )
            CRLPublicationURLs =  @(
                '65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl'
                '79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10'
                '6:http://pki.contoso.com/CertEnroll/%3%8%9.crl'
            )
            CRLOverlapUnits = 8
            CRLOverlapPeriod = 'Hours'
            CRLPeriodUnits = 1
            CRLPeriod = 'Months'
            ValidityPeriodUnits = 10
            ValidityPeriod = 'Years'
            DSConfigDN = 'CN=Configuration,DC=CONTOSO,DC=COM'
            DSDomainDN = 'DC=CONTOSO,DC=COM'
            AuditFilter = @(
                'StartAndStopADCS'
                'BackupAndRestoreCADatabase'
                'IssueAndManageCertificateRequests'
                'RevokeCertificatesAndPublishCRLs'
                'ChangeCASecuritySettings'
                'StoreAndRetrieveArchivedKeys'
                'ChangeCAConfiguration'
            )
            DependsOn        = '[AdcsCertificationAuthority]CertificateAuthority'
        }
    }
}
