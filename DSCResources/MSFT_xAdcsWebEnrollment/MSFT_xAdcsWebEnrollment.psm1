<#
    .SYNOPSIS
        Returns an object containing the current state information for the ADCS Web Enrollment.
    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
    .PARAMETER CAConfig
        CAConfig parameter string. Do not specify this if there is a local CA installed.
    .PARAMETER Credential
        If the Web Enrollment service is configured to use Standalone certification authority, then
        an account that is a member of the local Administrators on the CA is required. If the
        Web Enrollment service is configured to use an Enterprise CA, then an account that is a
        member of Domain Admins is required.
    .PARAMETER Ensure
        Specifies whether the Web Enrollment feature should be installed or uninstalled.
    .OUTPUTS
        Returns an object containing the ADCS Web Enrollment state information.
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

        [Parameter()]
        [String]
        $CAConfig,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    $ADCSParams = @{
        IsSingleInstance = $IsSingleInstance
        Credential = $Credential
        Ensure = $Ensure
    }

    if ($CAConfig)
    {
        $ADCSParams += @{
            CAConfig = $CAConfig
        }
    } # if

    $ADCSParams += @{
        IsCAWeb = Test-TargetResource @ADCSParams
    }
    return $ADCSParams
} # Function Get-TargetResource

<#
    .SYNOPSIS
        Installs or uinstalls the ADCS Web Enrollment from the server.
    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
    .PARAMETER CAConfig
        CAConfig parameter string. Do not specify this if there is a local CA installed.
    .PARAMETER Credential
        If the Web Enrollment service is configured to use Standalone certification authority, then
        an account that is a member of the local Administrators on the CA is required. If the
        Web Enrollment service is configured to use an Enterprise CA, then an account that is a
        member of Domain Admins is required.
    .PARAMETER Ensure
        Specifies whether the Web Enrollment feature should be installed or uninstalled.
#>
Function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [String]
        $CAConfig,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    if (-not $CAConfig)
    {
        $ADCSParams = @{
            Credential = $Credential
        }
    }
    else
    {
        $ADCSParams = @{
            CAConfig = $CAConfig
            Credential = $Credential
        }
    } # if

    switch ($Ensure)
    {
        'Present'
        {
            (Install-AdcsWebEnrollment @ADCSParams -Force).ErrorString
        }
        'Absent'
        {
            (Uninstall-AdcsWebEnrollment -Force).ErrorString
        }
    } # switch
} # Function Set-TargetResource

<#
    .SYNOPSIS
        Tests is the ADCS Web Enrollment is in the desired state.
    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
    .PARAMETER CAConfig
        CAConfig parameter string. Do not specify this if there is a local CA installed.
    .PARAMETER Credential
        If the Web Enrollment service is configured to use Standalone certification authority, then
        an account that is a member of the local Administrators on the CA is required. If the
        Web Enrollment service is configured to use an Enterprise CA, then an account that is a
        member of Domain Admins is required.
    .PARAMETER Ensure
        Specifies whether the Web Enrollment feature should be installed or uninstalled.
    .OUTPUTS
        Returns true if the ADCS Web Enrollment is in the desired state.
#>
Function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [String]
        $CAConfig,

        [Parameter(Mandatory = $true)]
        [pscredential] $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    if (-not $CAConfig)
    {
        $ADCSParams = @{
            Credential = $Credential
        }
    }
    else
    {
        $ADCSParams = @{
            CAConfig = $CAConfig
            Credential = $Credential
        }
    } # if

    try
    {
        $null = Install-AdcsWebEnrollment @ADCSParams -WhatIf
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
        } # switch
    }
    catch
    {
        Write-verbose $_
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
        } # switch
    } # try
} # Function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
