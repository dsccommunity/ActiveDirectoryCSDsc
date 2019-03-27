$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the ADCS Deployment Resource Common Module.
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ActiveDirectoryCSDsc.CommonHelper' `
            -ChildPath 'ActiveDirectoryCSDsc.CommonHelper.psm1'))

# Import the ADCS Deployment Resource Helper Module.
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ActiveDirectoryCSDsc.ResourceHelper' `
            -ChildPath 'ActiveDirectoryCSDsc.ResourceHelper.psm1'))

# Import Localization Strings.
$LocalizedData = Get-LocalizedData `
    -ResourceName 'MSFT_AdcsAiaExtension' `
    -ResourcePath (Split-Path -Parent $script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
        Gets the current certificate Authority Information Access (AIA) Uniform Resource Identifiers (URI)
        settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
        Not used in Get-TargetResource.

    .PARAMETER AiaUri
        Specifies the URI location where issuer of certificate is located.
        Not used in Get-TargetResource.

    .PARAMETER RestartService
        Specifies if the service should be restarted.
        Not used in Get-TargetResource.

    .PARAMETER Ensure
        Ensures that the Authority Information Access (AIA) Uniform Resource Identifiers (URI) is Present or Absent.
        Not used in Get-TargetResource.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AiaUri,

        [Parameter()]
        [System.Boolean]
        $RestartService,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message $localizedData.GetAiaUriPaths

    [System.Array] $currentAiaUriList = (Get-CAAuthorityInformationAccess).Where( {
            $_.AddToCertificateAia -eq $true
        } ).Uri

    return @{
        AiaUri      = $currentAiaUriList
        Ensure           = $Ensure
        IsSingleInstance = $IsSingleInstance
        RestartService   = $RestartService
    }
}

<#
    .SYNOPSIS
        Configures the current Authority Information Access (AIA) settings for the certification authority.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER AiaUri
        Specifies the URI location where issuer of certificate is located.

    .PARAMETER RestartService
        Specifies if the service should be restarted.

    .PARAMETER Ensure
        Ensures that the Authority Information Access (AIA) Uniform Resource Identifiers (URI) is Present or Absent.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AiaUri,

        [Parameter()]
        [System.Boolean]
        $RestartService,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $currentState = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq 'Present')
    {
        foreach ($uri in $currentState.AiaUri)
        {
            if ($AiaUri -notcontains $item)
            {
                Write-Verbose -Message ($localizedData.RemoveAiAUri -f $item)
                Remove-CAAuthorityInformationAccess -Uri $item -AddToCertificateAIA -Force
            }
        }

        foreach ($uri in $AiaUri)
        {
            if ($currentState.AiaUri -contains $field)
            {
                Write-Verbose -Message ($localizedData.RemoveAiAUri -f $field)
                Remove-CAAuthorityInformationAccess -Uri $field -AddToCertificateAIA -Force
            }

            Write-Verbose -Message ($localizedData.AddAiAUri -f $field)
            Add-CAAuthorityInformationAccess -Uri $field -AddToCertificateAIA -Force
        }
    }
    else
    {
        foreach ($field in $AiaUri)
        {
            Write-Verbose -Message ($localizedData.RemoveAiaUri -f $field)
            Remove-CAAuthorityInformationAccess -Uri $field -Force -ErrorAction Stop
        }
    }

    if ($RestartService)
    {
        Write-Verbose -Message $localizedData.RestartService
        Restart-ServiceIfExists -Name CertSvc
    }
}

<#
    .SYNOPSIS
        Tests the current certification authority AddToCertificateAia (boolean) and Uniform Resource Identifiers (URI)
        settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER AiaUri
        Specifies the URI location where issuer of certificate is located.

    .PARAMETER RestartService
        Specifies if the service should be restarted.

    .PARAMETER Ensure
        Ensures that the Authority Information Access (AIA) Uniform Resource Identifiers (URI) is Present or Absent.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AiaUri,

        [Parameter()]
        [System.Boolean]
        $RestartService,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $currentState = Get-TargetResource @PSBoundParameters

    $inDesiredState = $true

    if ($Ensure -eq 'Present')
    {
        if ($currentState.AiaUri.Count -ne $AiaUri.Count)
        {
            if ($null -ne $currentState.AiaUri)
            {
                $compareAiaUriPaths = Compare-Object -ReferenceObject $AiaUri -DifferenceObject $currentState.AiaUri -PassThru

                # Desired state AIA URI path(s) not found in reference set.
                $desiredAiaUriPathsMissing = $compareAiaUriPaths.Where( {
                        $_.SideIndicator -eq '<='
                    } ) -join ', '

                # AIA URI path(s) found in $currentState that do not match $AiaUri desired state.
                $notDesiredAiaUriPathsFound = $compareAiaUriPaths.Where( {
                        $_.SideIndicator -eq '=>'
                    } ) -join ', '

                if ($desiredAiaUriPathsMissing)
                {
                    Write-Verbose -Message ($localizedData.DesiredAiaPathsMissing -f $desiredAiaUriPathsMissing)
                    $inDesiredState = $false
                }

                if ($notDesiredAiaUriPathsFound)
                {
                    Write-Verbose -Message ($localizedData.AdditionalAiaPathsFound -f $notDesiredAiaUriPathsFound)
                    $inDesiredState = $false
                }
            }
            else
            {
                $aiaUriPathList = $AiaUri -join ', '

                Write-Verbose -Message ($localizedData.AiaPathsNull -f $aiaUriPathList)
                $inDesiredState = $false
            }
        }

        foreach ($uri in $currentState.AiaUri)
        {
            if ($uri -notin $AiaUri)
            {
                Write-Verbose -Message ($localizedData.IncorrectAiaUriFound -f $uri)
                $inDesiredState = $false
            }
        }
    }
    else
    {
        foreach ($uri in $AiaUri)
        {
            if ($uri -in $currentState.AiaUri)
            {
                Write-Verbose -Message ($localizedData.EnsureAbsentButUriPathsExist -f $uri)
                $inDesiredState = $false
            }
        }
    }

    return $inDesiredState
}

Export-ModuleMember -Function Get-TargetResource, Test-TargetResource, Set-TargetResource
