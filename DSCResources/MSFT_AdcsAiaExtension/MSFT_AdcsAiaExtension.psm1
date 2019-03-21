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
        Gets the current certification authority AddToCertificateAia (boolean) and Uniform Resource Identifiers (URI)
        settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'..

    .PARAMETER AiaUriPath
        Array of Uniform Resource Identifiers (URI) used to provide a location from where the issuer of this certificate is located.

    .PARAMETER RestartService
        Specifies if the CertSvc service should be restarted to immediately apply the settings.

    .PARAMETER Ensure
        Ensures that the Authority Information Access (AIA) Uniform Resource Identifiers (URI) is Present or Absent.
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
        $AiaUriPath,

        [Parameter()]
        [System.Boolean]
        $RestartService,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message $localizedData.GetAiaUriPaths

    [System.Array] $currentAiaUriPathList = (Get-CAAuthorityInformationAccess).Where( {
        $_.AddToCertificateAia -eq $true
    } ).Uri

    return @{
        AiaUriPath      = $currentAiaUriPathList
        Ensure           = $Ensure
        IsSingleInstance = $IsSingleInstance
        RestartService   = $RestartService
    }
}

<#
    .SYNOPSIS
        Configures the current Authority Information Access (AIA) settings for the certification authority.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'..

    .PARAMETER AiaUriPath
        Array of Uniform Resource Identifiers (URI) used to provide a location from where the issuer of this certificate is located.

    .PARAMETER RestartService
        Specifies if the CertSvc service should be restarted to immediately apply the settings.

    .PARAMETER Ensure
        Specifies if the AIA responder URI should be present or absent.
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
        $AiaUriPath,

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
        foreach ($oldField in $currentState.AiaUriPath)
        {
            Write-Verbose -Message ($localizedData.RemoveAiaUriPaths -f $oldField)
            Remove-CAAuthorityInformationAccess -Uri $oldField -Force -ErrorAction Stop
        }

        foreach ($newField in $AiaUriPath)
        {
            Write-Verbose -Message ($localizedData.AddAiaUriPaths -f $newField)
            Add-CAAuthorityInformationAccess -Uri $newField -AddToCertificateAia -Force -ErrorAction Stop
        }
    }
    else
    {
        foreach ($field in $AiaUriPath)
        {
            Write-Verbose -Message ($localizedData.RemoveAiaUriPaths -f $field)
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
        Specifies the resource is a single instance, the value must be 'Yes'..

    .PARAMETER AiaUriPath
        Array of Uniform Resource Identifiers (URI) used to provide a location from where the issuer of this certificate is located.

    .PARAMETER RestartService
        Specifies if the CertSvc service should be restarted to immediately apply the settings.

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
        $AiaUriPath,

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
        if ($currentState.AiaUriPath.Count -ne $AiaUriPath.Count)
        {
            if ($null -ne $currentState.AiaUriPath)
            {
                $compareAiaUriPaths = Compare-Object -ReferenceObject $AiaUriPath -DifferenceObject $currentState.AiaUriPath -PassThru

                # Desired state AIA URI path(s) not found in reference set.
                $desiredAiaUriPathsMissing  = $compareAiaUriPaths.Where( {
                    $_.SideIndicator -eq '<='
                } ) -join ', '

                # AIA URI path(s) found in $currentState that do not match $AiaUriPath desired state.
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
                $aiaUriPathList = $AiaUriPath -join ', '

                Write-Verbose -Message ($localizedData.AiaPathsNull -f $aiaUriPathList)
                $inDesiredState = $false
            }
        }

        foreach ($uri in $currentState.AiaUriPath)
        {
            if ($uri -notin $AiaUriPath)
            {
                Write-Verbose -Message ($localizedData.IncorrectAiaUriFound -f $uri)
                $inDesiredState = $false
            }
        }
    }
    else
    {
        foreach ($uri in $AiaUriPath)
        {
            if ($uri -in $currentState.AiaUriPath)
            {
                Write-Verbose -Message ($localizedData.EnsureAbsentButUriPathsExist -f $uri)
                $inDesiredState = $false
            }
        }
    }

    return $inDesiredState
}

Export-ModuleMember -Function Get-TargetResource, Test-TargetResource, Set-TargetResource
