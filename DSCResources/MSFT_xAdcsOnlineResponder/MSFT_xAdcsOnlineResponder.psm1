# This resource can be used to install an ADCS Online Responder after the feature has been installed on the server.
# For more information on ADCS Online Responders, see https://technet.microsoft.com/en-us/library/cc725958.aspx

#region Get Resource
Function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present',

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $ADCSParams = @{
        Credential = $Credential
        Ensure = $Ensure
        Name = $Name }

    $ADCSParams += @{ StateOK = Test-TargetResource @ADCSParams }
    Return $ADCSParams
}
#endregion

#region Set Resource
Function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present',

        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $ADCSParams = @{ Credential = $Credential }

    switch ($Ensure) {
        'Present' {(Install-AdcsOnlineResponder @ADCSParams -Force).ErrorString}
        'Absent' {(Uninstall-AdcsOnlineResponder -Force).ErrorString}
        }
}
#endregion

#region Test Resource
Function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present',

        [Parameter(Mandatory)]
        [pscredential]$Credential,
        
        [Parameter(Mandatory)]
        [string]$Name
    )

    $ADCSParams = @{ Credential = $Credential }

    try{
        $test = Install-AdcsOnlineResponder @ADCSParams -WhatIf
        Switch ($Ensure) {
            'Present' {return $false}
            'Absent' {return $true}
            }
    }
    catch{
        Write-verbose $_
        Switch ($Ensure) {
            'Present' {return $true}
            'Absent' {return $false}
            }
    }
}
#endregion

Export-ModuleMember -Function *-TargetResource
