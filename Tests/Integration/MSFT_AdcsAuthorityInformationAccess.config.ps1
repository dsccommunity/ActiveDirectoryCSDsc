configuration MSFT_AdcsAuthorityInformationAccess_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAuthorityInformationAccess Integration_Test
        {
            IsSingleInstance    = 'Yes'
            AiaList             = $Node.AiaList
            OcspList            = $Node.OcspList
            AllowRestartService = $Node.AllowRestartService
        }
    }
}
