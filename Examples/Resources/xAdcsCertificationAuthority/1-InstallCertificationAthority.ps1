<#
    .EXAMPLE
        This example will add the Active Directory Certificate Services Certificate Authority
        feature to a server and configure it as a certificate authority enterprise root CA.
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

    Import-DscResource -Module xAdcsDeployment

    Node $AllNodes.NodeName
    {
        WindowsFeature ADCS-Cert-Authority
        {
            Ensure = 'Present'
            Name   = 'ADCS-Cert-Authority'
        }

        xAdcsCertificationAuthority CertificateAuthority
        {
            Ensure     = 'Present'
            Credential = $Credential
            CAType     = 'EnterpriseRootCA'
            DependsOn  = '[WindowsFeature]ADCS-Cert-Authority'
        }
    }
}
