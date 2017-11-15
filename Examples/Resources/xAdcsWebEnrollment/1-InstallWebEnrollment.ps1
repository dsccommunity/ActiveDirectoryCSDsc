<#
    .EXAMPLE
        This example will add the Active Directory Certificate Services Certification
        Authority Web Enrollment feature to a server and configure it as a web
        enrollment server.
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
        WindowsFeature ADCS-Web-Enrollment
        {
            Ensure = 'Present'
            Name   = 'ADCS-Web-Enrollment'
        }

        xAdcsWebEnrollment WebEnrollment
        {
            Ensure           = 'Present'
            IsSingleInstance = 'Yes'
            Credential       = $Credential
            DependsOn        = '[WindowsFeature]ADCS-Web-Enrollment'
        }
    }
}
