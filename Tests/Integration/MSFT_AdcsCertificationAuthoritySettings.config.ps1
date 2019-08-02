configuration MSFT_AdcsCertificationAuthoritySettings_Config {
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost {
        AdcsCertificationAuthoritySettings Integration_Test {
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
        }
    }
}
