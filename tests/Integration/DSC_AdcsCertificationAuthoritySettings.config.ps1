configuration DSC_AdcsCertificationAuthoritySettings_Config
{
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost
    {
        AdcsCertificationAuthoritySettings Integration_Test
        {
            IsSingleInstance      = 'Yes'
            CACertPublicationURLs = $Node.CACertPublicationURLs
            CRLPublicationURLs    = $Node.CRLPublicationURLs
            CRLOverlapUnits       = $Node.CRLOverlapUnits
            CRLOverlapPeriod      = $Node.CRLOverlapPeriod
            CRLPeriodUnits        = $Node.CRLPeriodUnits
            CRLPeriod             = $Node.CRLPeriod
            ValidityPeriodUnits   = $Node.ValidityPeriodUnits
            ValidityPeriod        = $Node.ValidityPeriod
            DSConfigDN            = $Node.DSConfigDN
            DSDomainDN            = $Node.DSDomainDN
            AuditFilter           = $Node.AuditFilter
        }
    }
}
