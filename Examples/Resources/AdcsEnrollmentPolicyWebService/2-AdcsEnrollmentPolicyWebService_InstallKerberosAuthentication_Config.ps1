<#PSScriptInfo
.VERSION 1.0.0
.GUID 86676cde-d149-410b-bb23-d765163f2490
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
        This example will add the Active Directory Certificate Services Enrollment
        Policy Web Service feature to a server and install a new instance to
        accepting Kerberos authentication. The Enrollment Policy Web Service
        will operate not operate in key-based renewal mode because this is not
        supported by Kerberos authentication. The local machine certificate with the
        thumbprint 'f0262dcf287f3e250d1760508c4ca87946006e1e' will be used for the
        IIS web site for SSL encryption.
#>
Configuration AdcsEnrollmentPolicyWebService_InstallKerberosAuthentication_Config
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
