<#
    .EXAMPLE
        This example will add the retire an Active Directory Certificate Services
        certificate authority from a node and uninstall the Active Directory Certificate
        Services certification authority feature.
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

    Node $AllNodes.NodeName
    {
        xAdcsCertificationAuthority CertificateAuthority
        {
            Ensure = 'Absent'
            CAType = 'EnterpriseRootCA'
        }

        WindowsFeature ADCS-Cert-Authority
        {
            Ensure    = 'Absent'
            Name      = 'ADCS-Cert-Authority'
            DependsOn = '[xADCSCertificationAuthority]CertificateAuthority'
        }
    }
}
