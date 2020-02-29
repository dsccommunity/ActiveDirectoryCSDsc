configuration DSC_AdcsAuthorityInformationAccess_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsAuthorityInformationAccess Integration_Test
        {
            IsSingleInstance    = 'Yes'
            AiaUri              = $Node.AiaUri
            OcspUri             = $Node.OcspUri
            AllowRestartService = $Node.AllowRestartService
        }
    }
}
