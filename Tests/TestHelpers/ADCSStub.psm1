# This section suppresses rules PsScriptAnalyzer may catch in stub functions.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]

[CmdletBinding()]
param ()

<#
    .SYNOPSIS
        This is stub cmdlets for module: ADCSAdministration version: 2.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Add-CAAuthorityInformationAccess
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Switch]
        $AddToCertificateAia,

        [Parameter()]
        [Switch]
        $AddToCertificateOcsp,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [Switch]
        ${Force}
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ADCSAdministration version: 2.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Get-CAAuthorityInformationAccess
{
    [CmdletBinding()]
    param
    (
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

<#
    .SYNOPSIS
        This is stub cmdlets for module: ADCSAdministration version: 2.0.0.0 which can be used in
        Pester unit tests to be able to test code without having the actual module installed.

    .NOTES
        Generated from module System.Collections.Hashtable on
        operating system Microsoft Windows Server 2012 R2 Datacenter 64-bit (6.3.9600)
#>
function Remove-CAAuthorityInformationAccess
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Switch]
        $AddToCertificateAia,

        [Parameter()]
        [Switch]
        $AddToCertificateOcsp,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [Switch]
        ${Force}
    )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}
