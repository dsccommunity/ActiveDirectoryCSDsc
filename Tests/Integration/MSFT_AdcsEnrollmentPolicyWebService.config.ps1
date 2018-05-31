configuration MSFT_AdcsEnrollmentPolicyWebService_Config {
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    node localhost {
        AdcsEnrollmentPolicyWebService Integration_Test {
            AuthenticationType = $Node.AuthenticationType
            SslCertThumbprint  = $Node.SslCertThumbprint
            Credential         = $Node.Credential
            KeyBasedRenewal    = $Node.KeyBasedRenewal
            Ensure             = $Node.Ensure
        }
    }
}
