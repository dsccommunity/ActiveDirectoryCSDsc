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
# Get-TargetResource -Name 'Test' -Credential (Get-Credential)
# Expected Outcome: Return a table of appropriate values.
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
# Set-TargetResource -Name 'Test' -Credential (Get-Credential)
# Expected Outcome: Setup Certificate Services Online Responder on this node.
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
# Test-TargetResource -Name 'Test' -Credential (Get-Credential)
# Expected Outcome: Returns a boolean indicating whether Certificate Services Online Responder is installed on this node.
#endregion

Export-ModuleMember -Function *-TargetResource
