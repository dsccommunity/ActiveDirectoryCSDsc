configuration MSFT_AdcsCertificationAuthority_Uninstall_Config {
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost {
        AdcsCertificationAuthority Integration_Test {
            IsSingleInstance = 'Yes'
            CAType           = 'StandaloneRootCA'
            Credential       = $Node.AdminCred
            Ensure           = 'Absent'
        }
    }
}
