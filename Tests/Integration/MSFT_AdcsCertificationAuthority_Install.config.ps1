configuration MSFT_AdcsCertificationAuthority_Install_Config {
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost {
        AdcsCertificationAuthority Integration_Test {
            CAType     = 'StandaloneRootCA'
            Credential = $Node.AdminCred
            Ensure     = 'Present'
        }
    }
}
