<#
    .EXAMPLE
        This example will add the Active Directory Certificate Services Online Responder
        feature to a server and configure it as an Online Certificate Status Protocol (OCSP)
        server.
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -Module xAdcsDeployment

    WindowsFeature ADCS-Online-Cert
    {
        Ensure = 'Present'
        Name   = 'ADCS-Online-Cert'
    }

    xAdcsOnlineResponder OnlineResponder
    {
        Ensure           = 'Present'
        IsSingleInstance = 'Yes'
        Credential       = $Node.Credential
        DependsOn        = '[WindowsFeature]ADCS-Online-Cert'
    }
}
