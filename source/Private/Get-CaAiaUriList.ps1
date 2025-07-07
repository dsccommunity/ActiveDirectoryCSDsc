<#
    .SYNOPSIS
        Return the current Authority Information Access list set on the
        certificate authority, either for the AIA or Online Responder OCSP
        extensions as an array of strings.

    .PARAMETER ExtensionType
        The type of the extension to return the URI list for.
#>
function Get-CaAiaUriList
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AddToCertificateAia', 'AddToCertificateOcsp')]
        $ExtensionType
    )

    Write-Debug -Message ($script:localizedData.GettingAiaUrisMessage -f $ExtensionType)

    return (Get-CAAuthorityInformationAccess | Where-Object -Property $ExtensionType -Eq $true).Uri
}
