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

    xAdcsCertificationAuthority CertificateAuthority
    {
        Ensure = 'Absent'
    }

    WindowsFeature ADCS-Cert-Authority
    {
        Ensure    = 'Absent'
        Name      = 'ADCS-Cert-Authority'
        DependsOn = '[xADCSCertificationAuthority]CertificateAuthority'
    }
}