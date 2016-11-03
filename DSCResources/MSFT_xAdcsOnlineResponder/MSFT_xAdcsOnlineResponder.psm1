<#
    .SYNOPSIS
        Returns an object containing the current state information for the ADCS Online Responder.
    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.
    .PARAMETER Ensure
        Specifies whether the Online Responder feature should be installed or uninstalled.
    .OUTPUTS
        Returns an object containing the ADCS Online Responder state information.
#>
Function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    $ADCSParams = @{
        IsSingleInstance = $IsSingleInstance
        Credential = $Credential
        Ensure = $Ensure
    }

    $ADCSParams += @{
        StateOK = Test-TargetResource @ADCSParams
    }
    Return $ADCSParams
} # Function Get-TargetResource

<#
    .SYNOPSIS
        Installs or uinstalls the ADCS Online Responder from the server.
    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.
    .PARAMETER Ensure
        Specifies whether the Online Responder feature should be installed or uninstalled.
#>
Function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    $ADCSParams = @{
        Credential = $Credential
    }

    switch ($Ensure)
    {
        'Present'
        {
            (Install-AdcsOnlineResponder @ADCSParams -Force).ErrorString
        }
        'Absent'
        {
            (Uninstall-AdcsOnlineResponder -Force).ErrorString
        }
    } # Switch
} # Function Set-TargetResource

<#
    .SYNOPSIS
        Tests is the ADCS Online Responder is in the desired state.
    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.
    .PARAMETER Ensure
        Specifies whether the Online Responder feature should be installed or uninstalled.
    .OUTPUTS
        Returns true if the ADCS Online Responder is in the desired state.
#>
Function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    $ADCSParams = @{
        Credential = $Credential
    }

    try
    {
        $null = Install-AdcsOnlineResponder @ADCSParams -WhatIf
        Switch ($Ensure)
        {
            'Present'
            {
                return $false
            }
            'Absent'
            {
                return $true
            }
        } # Switch
    }
    catch
    {
        Write-verbose -Verbose $_
        Switch ($Ensure)
        {
            'Present'
            {
                return $true
            }
            'Absent'
            {
                return $false
            }
        } # Switch
    } # try
} # Function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
