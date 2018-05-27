configuration MSFT_AdcsEnrollmentPolicyWebService_Config {
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost {
        AdcsEnrollmentPolicyWebService Integration_Test {
            AuthenticationType = $Node.AuthenticationType
            SSLCertThumbprint  = $Node.SSLCertThumbprint
            Credential         = $Node.Credential
            KeyBasedRenewal    = $Node.KeyBasedRenewal
            Ensure             = $Node.Ensure
        }
    }
}
