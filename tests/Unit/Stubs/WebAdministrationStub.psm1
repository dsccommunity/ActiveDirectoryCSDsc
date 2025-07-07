# This section suppresses rules PsScriptAnalyzer may catch in stub functions.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]

# Name: WebAdministration

[CmdletBinding()]
param ()

function Get-WebApplication
{
    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkID=268826')]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [string]
        ${Site},

        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [string]
        ${Name})
    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand

}
