@{
    CACertPublicationURLs = @{
        Type         = 'String[]'
        CurrentValue = @('1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt', '2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11')
        NewValue     = @('1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt', '2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt')
        MockedValue  = '1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11'
        SetValue     = '1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt'
    }
    CRLPublicationURLs    = @{
        Type         = 'String[]'
        CurrentValue = @('65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl', '79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10')
        NewValue     = @('65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl', '6:http://pki.contoso.com/CertEnroll/%3%8%9.crl')
        MockedValue  = '65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10'
        SetValue     = '65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n6:http://pki.contoso.com/CertEnroll/%3%8%9.crl'
    }
    CRLOverlapUnits       = @{
        Type         = 'UInt32'
        CurrentValue = 24
        NewValue     = 12
        MockedValue  = 24
        SetValue     = 12
    }
    CRLOverlapPeriod      = @{
        Type         = 'String'
        CurrentValue = 'Hours'
        NewValue     = 'Days'
        MockedValue  = 'Hours'
        SetValue     = 'Days'
    }
    CRLPeriodUnits        = @{
        Type         = 'UInt32'
        CurrentValue = 5
        NewValue     = 10
        MockedValue  = 5
        SetValue     = 10
    }
    CRLPeriod             = @{
        Type         = 'String'
        CurrentValue = 'Years'
        NewValue     = 'Months'
        MockedValue  = 'Years'
        SetValue     = 'Months'
    }
    ValidityPeriodUnits   = @{
        Type         = 'UInt32'
        CurrentValue = 2
        NewValue     = 4
        MockedValue  = 2
        SetValue     = 4
    }
    ValidityPeriod        = @{
        Type         = 'String'
        CurrentValue = 'Days'
        NewValue     = 'Hours'
        MockedValue  = 'Days'
        SetValue     = 'Hours'
    }
    DSConfigDN            = @{
        Type         = 'String'
        CurrentValue = 'CN=Configuration,DC=CONTOSO,DC=COM'
        NewValue     = 'CN=Configuration,DC=SOMEWHERE,DC=COM'
        MockedValue  = 'CN=Configuration,DC=CONTOSO,DC=COM'
        SetValue     = 'CN=Configuration,DC=SOMEWHERE,DC=COM'
    }
    DSDomainDN            = @{
        Type         = 'String'
        CurrentValue = 'DC=CONTOSO,DC=COM'
        NewValue     = 'DC=SOMEWHERE,DC=COM'
        MockedValue  = 'DC=CONTOSO,DC=COM'
        SetValue     = 'DC=SOMEWHERE,DC=COM'
    }
    AuditFilter           = @{
        Type         = 'Flags'
        CurrentValue = @('StartAndStopADCS', 'ChangeCAConfiguration')
        NewValue     = @('BackupAndRestoreCADatabase', 'ChangeCAConfiguration')
        MockedValue  = 65
        SetValue     = 66
    }
}
