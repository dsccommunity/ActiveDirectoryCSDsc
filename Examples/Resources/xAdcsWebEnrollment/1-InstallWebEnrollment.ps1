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
        $NodeName = 'localhost'
    )

    WindowsFeature ADCS-Web-Enrollment
    {
        Ensure = 'Present'
        Name   = 'ADCS-Web-Enrollment'
    }

    xAdcsWebEnrollment WebEnrollment
    {
        Ensure           = 'Present'
        IsSingleInstance = 'Yes'
        Credential       = $Node.Credential
        DependsOn        = '[WindowsFeature]ADCS-Web-Enrollment'
    }
}
