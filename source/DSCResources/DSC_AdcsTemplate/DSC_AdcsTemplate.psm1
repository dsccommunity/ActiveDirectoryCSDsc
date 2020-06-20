$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the ADCS Deployment Resource Common Module.
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ActiveDirectoryCSDsc.Common' `
            -ChildPath 'ActiveDirectoryCSDsc.Common.psm1'))

Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

# Import Localization Strings.
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Returns an object containing the current state information for a CA Template.

    .PARAMETER Name
        Specifies the name of a certificate template. This name must always be the
        template short name without spaces, and not the template display name.

    .PARAMETER Ensure
        Specifies whether the Template should be added or removed.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingAdcsTemplateStatusMessage -f $Name)
        ) -join '' )

    try
    {
        $CATemplate = Get-CATemplate -Verbose:$false | Where-Object -Property Name -eq $Name
    }
    catch
    {
        New-InvalidOperationException -Message $script:localizedData.InvalidOperationGettingAdcsTemplateMessage -ErrorRecord $_
    }

    if ($CATemplate)
    {
        # Template is added
        $Ensure = 'Present'
    }
    else
    {
        # Template is removed
        $Ensure = 'Absent'
    }

    return @{
        Name   = $Name
        Ensure = $Ensure
    }
} # function Get-TargetResource

<#
    .SYNOPSIS
        Adds or removes a CA Template.

    .PARAMETER Name
        Specifies the name of a certificate template. This name must always be the
        template short name without spaces, and not the template display name.

    .PARAMETER Ensure
        Specifies whether the Template should be added or removed.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.SettingAdcsTemplateStatusMessage -f $Name)
        ) -join '' )

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.AddingAdcsTemplateMessage -f $Name)
            ) -join '' )

        try
        {
            Add-CATemplate -Name $Name -Verbose:$false
        }
        catch
        {
            New-InvalidOperationException -Message $($script:localizedData.InvalidOperationAddingAdcsTemplateMessage -f $Name) -ErrorRecord $_
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.RemovingAdcsTemplateMessage -f $Name)
            ) -join '' )

        try
        {
            Remove-CATemplate -Name $Name -Force -Verbose:$false
        }
        catch
        {
            New-InvalidOperationException -Message $($script:localizedData.InvalidOperationRemovingAdcsTemplateMessage -f $Name) -ErrorRecord $_
        }
    }
} # function Set-TargetResource

<#
    .SYNOPSIS
        Tests if the CA Template is in the desired state.

    .PARAMETER Name
        Specifies the name of a certificate template. This name must always be the
        template short name without spaces, and not the template display name.

    .PARAMETER Ensure
        Specifies whether the Template should be added or removed.

    .OUTPUTS
        Returns true if the CA Template is in the desired state.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingAdcsTemplateStatusMessage -f $Name)
        ) -join '' )

    $currentState = Get-TargetResource -Name $Name
    if ($Ensure -eq 'Present')
    {
        if ($currentState.Ensure -eq 'Present')
        {
            # CA Template is added and should be - change not required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsTemplateAddedAndShouldBeMessage -f $Name)
                ) -join '' )

            return $true
        }
        else
        {
            # CA Template is not added but should be - change required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsTemplateNotAddedButShouldBeMessage -f $Name)
                ) -join '' )

            return $false
        }
    }
    else
    {
        if ($currentState.Ensure -eq 'Present')
        {
            # CA Template is installed and should not be - change required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsTemplateAddedButShouldNotBeMessage -f $Name)
                ) -join '' )

            return $false
        }
        else
        {
            # CA Template is not added and should not be - change not required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsTemplateNotAddedAndShouldNotBeMessage -f $Name)
                ) -join '' )

            return $true
        }
    }
} # function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
