@{
    ParameterList = @(
        @{
            Name    = 'CACertPublicationURLs'
            Type    = 'String[]'
            Default = @('1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt','2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11')
            TestVal = @('1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt','2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt')
        },
        @{
            Name    = 'CRLPublicationURLs'
            Type    = 'String[]'
            Default = @('65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl','79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10')
            TestVal = @('65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl','6:http://pki.contoso.com/CertEnroll/%3%8%9.crl')
        },
        @{
            Name    = 'CRLOverlapUnits'
            Type    = 'Uint32'
            Default = 24
            TestVal = 12
        },
        @{
            Name    = 'CRLOverlapPeriod'
            Type    = 'String'
            Default = 'Hours'
            TestVal = 'Days'
        },
        @{
            Name    = 'CRLPeriodUnits'
            Type    = 'Uint32'
            Default = 5
            TestVal = 10
        },
        @{
            Name    = 'CRLPeriod'
            Type    = 'String'
            Default = 'Years'
            TestVal = 'Months'
        },
        @{
            Name    = 'ValidityPeriodUnits'
            Type    = 'Uint32'
            Default = 2
            TestVal = 4
        },
        @{
            Name    = 'ValidityPeriod'
            Type    = 'String'
            Default = 'Days'
            TestVal = 'Hours'
        },
        @{
            Name    = 'DSConfigDN'
            Type    = 'String'
            Default = 'CN=Configuration,DC=CONTOSO,DC=COM'
            TestVal = 'CN=Configuration,DC=SOMEWHERE,DC=COM'
        },
        @{
            Name    = 'DSDomainDN'
            Type    = 'String'
            Default = 'DC=CONTOSO,DC=COM'
            TestVal = 'DC=SOMEWHERE,DC=COM'
        },
        @{
            Name    = 'DSDomainDN'
            Type    = 'String[]'
            Default = @('StartAndStopADCS','ChangeCAConfiguration')
            TestVal = @('BackupAndRestoreCADatabase','ChangeCAConfiguration')
        }
    )
}
