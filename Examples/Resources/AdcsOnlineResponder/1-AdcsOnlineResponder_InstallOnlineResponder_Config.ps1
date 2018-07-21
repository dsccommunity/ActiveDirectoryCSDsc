#Requires -module ActiveDirectoryCSDsc

<#
    .DESCRIPTION
        This example will add the Active Directory Certificate Services Online Responder
        feature to a server and configure it as an Online Certificate Status Protocol (OCSP)
        server.
#>
Configuration Example
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
        WindowsFeature ADCS-Online-Cert
        {
            Ensure = 'Present'
            Name   = 'ADCS-Online-Cert'
        }

        AdcsOnlineResponder OnlineResponder
        {
            Ensure           = 'Present'
            IsSingleInstance = 'Yes'
            Credential       = $Credential
            DependsOn        = '[WindowsFeature]ADCS-Online-Cert'
        }
    }
}
