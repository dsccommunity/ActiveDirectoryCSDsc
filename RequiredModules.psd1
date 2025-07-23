@{
    PSDependOptions                = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild                    = 'latest'
    PSScriptAnalyzer               = 'latest'
    ConvertToSARIF                 = 'latest' # cSpell: disable-line

    <#
        If preview release of Pester prevents release we should temporary shift
        back to stable.
    #>
    Pester                         = @{
        Version    = 'latest'
        Parameters = @{
            AllowPrerelease = $false
        }
    }

    Plaster                        = 'latest'
    ModuleBuilder                  = 'latest'
    ChangelogManagement            = 'latest'
    Sampler                        = 'latest'
    'Sampler.GitHubTasks'          = 'latest'
    MarkdownLinkCheck              = 'latest'
    'DscResource.Test'             = 'latest'
    xDscResourceDesigner           = 'latest'

    # Build dependencies needed for using the module
    'DscResource.Base'             = @{
        Version    = 'latest'
        Parameters = @{
            AllowPrerelease = $true
        }
    }
    'DscResource.Common'           = 'latest'

    # Analyzer rules
    'DscResource.AnalyzerRules'    = 'latest'
    'Indented.ScriptAnalyzerRules' = 'latest'

    # Prerequisite modules for documentation.
    #'DscResource.DocGenerator'     = 'latest'
    'DscResource.DocGenerator'     = @{
        Version    = 'latest'
        Parameters = @{
            AllowPrerelease = $true
        }
    }
    PlatyPS                        = 'latest'
}
