<#
    .EXAMPLE
        This example will add the Active Directory Certificate Services Enrollment
        Policy Web Service feature to a server and install a new instance to
        accepting Kerberos authentication. The Enrollment Policy Web Service
        will operate not operate in key-based renewal mode because this is not
        supported by Kerberos authentication. The local machine certificate with the
        thumbprint 'f0262dcf287f3e250d1760508c4ca87946006e1e' will be used for the
        IIS web site for SSL encryption.
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -Module ActiveDirectoryCSDsc

    Node $AllNodes.NodeName
    {
        WindowsFeature ADCS-Enroll-Web-Pol
        {
            Ensure = 'Present'
            Name   = 'ADCS-Enroll-Web-Pol'
        }

        AdcsEnrollmentPolicyWebService EnrollmentPolicyWebService
        {
            AuthenticationType = 'Kerberos'
            SslCertThumbprint  = 'f0262dcf287f3e250d1760508c4ca87946006e1e'
            Credential         = $Credential
            KeyBasedRenewal    = $false
            Ensure             = 'Present'
            DependsOn          = '[WindowsFeature]ADCS-Enroll-Web-Pol'
        }
    }
}