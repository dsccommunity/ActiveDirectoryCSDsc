<#
    .EXAMPLE
        This example will add the retire an Active Directory Certificate Services
        certificate authority from a node and uninstall the Active Directory Certificate
        Services certification authority feature.

        It will set the Root CA common came to 'Contoso Root CA' and the CA distinguished
        name suffix to 'DC=CONTOSO,DC=COM'. If an existing CA root certificate exists
        in the Active Directory then it will be overwritten.
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
        xAdcsCertificationAuthority CertificateAuthority
        {
            Ensure                    = 'Absent'
            Credential                = $Credential
            CAType                    = 'EnterpriseRootCA'
            CACommonName              = 'Contoso Root CA'
            CADistinguishedNameSuffix = 'DC=CONTOSO,DC=COM'
            OverwriteExistingCAinDS   = $True
        }

        WindowsFeature ADCS-Cert-Authority
        {
            Ensure    = 'Absent'
            Name      = 'ADCS-Cert-Authority'
            DependsOn = '[xADCSCertificationAuthority]CertificateAuthority'
        }
    }
}
