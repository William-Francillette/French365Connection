# Generated with Microsoft365DSC version 1.23.823.1
# For additional information on how to use Microsoft365DSC, please visit https://aka.ms/M365DSC
param (
    [Parameter()]
    [String]
    $OrganizationName
)

Configuration M365TenantConfig
{
    param (
    )

    #$OrganizationName = $ConfigurationData.NonNodeData.OrganizationName

    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node localhost
    {
        AADAuthenticationStrengthPolicy "AADAuthenticationStrengthPolicy-test auth"
        {
            AllowedCombinations = @("windowsHelloForBusiness");
            Description         = "DSC_GraphAPIv2.0_DSC_";
            DisplayName         = "test auth";
            Ensure              = "Present";
            Id                  = "d24621eb-d64a-4b91-92bf-6cf5ae087f73";
            TenantId            = $OrganizationName;
            ManagedIdentity     = $true
        }
        AADAuthenticationStrengthPolicy "AADAuthenticationStrengthPolicy-Multifactor authentication"
        {
            AllowedCombinations = @("windowsHelloForBusiness", "fido2", "x509CertificateMultiFactor", "deviceBasedPush", "temporaryAccessPassOneTime", "temporaryAccessPassMultiUse", "password,microsoftAuthenticatorPush", "password,softwareOath", "password,hardwareOath", "password,sms", "password,voice", "federatedMultiFactor", "microsoftAuthenticatorPush,federatedSingleFactor", "softwareOath,federatedSingleFactor", "hardwareOath,federatedSingleFactor", "sms,federatedSingleFactor", "voice,federatedSingleFactor");
            Description         = "Combinations of methods that satisfy strong authentication, such as a password + SMS";
            DisplayName         = "Multifactor authentication";
            Ensure              = "Present";
            Id                  = "00000000-0000-0000-0000-000000000002";
            TenantId            = $OrganizationName;
            ManagedIdentity     = $true
        }
        AADAuthenticationStrengthPolicy "AADAuthenticationStrengthPolicy-Passwordless MFA"
        {
            AllowedCombinations = @("windowsHelloForBusiness", "fido2", "x509CertificateMultiFactor", "deviceBasedPush");
            Description         = "Passwordless methods that satisfy strong authentication, such as Passwordless sign-in with the Microsoft Authenticator";
            DisplayName         = "Passwordless MFA";
            Ensure              = "Present";
            Id                  = "00000000-0000-0000-0000-000000000003";
            TenantId            = $OrganizationName;
            ManagedIdentity     = $true
        }
        AADAuthenticationStrengthPolicy "AADAuthenticationStrengthPolicy-Phishing-resistant MFA"
        {
            AllowedCombinations = @("windowsHelloForBusiness", "fido2", "x509CertificateMultiFactor");
            Description         = "Phishing-resistant, Passwordless methods for the strongest authentication, such as a FIDO2 security key";
            DisplayName         = "Phishing-resistant MFA";
            Ensure              = "Present";
            Id                  = "00000000-0000-0000-0000-000000000004";
            TenantId            = $OrganizationName;
            ManagedIdentity     = $true
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA101-Admins-BaseProtection-AllApps-AnyPlatform-MFA"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("mfa");
            ClientAppTypes                           = @("all");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA101-Admins-BaseProtection-AllApps-AnyPlatform-MFA";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Breakglass");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "OR";
            Id                                       = "01415df6-a5c2-490f-bf66-70d2489a08ab";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @("CA-Persona-Admins");
            IncludeLocations                         = @();
            IncludePlatforms                         = @();
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @("AlexW@001q1.onmicrosoft.com");
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @();
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @();
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA201-Internals-BaseProtection-AllApps-AnyPlatform-MFA"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("mfa");
            ClientAppTypes                           = @("all");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA201-Internals-BaseProtection-AllApps-AnyPlatform-MFA";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Breakglass");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "OR";
            Id                                       = "bf015541-52a5-417b-b0e8-49d3f4211f1d";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @("CA-Persona-Internals");
            IncludeLocations                         = @();
            IncludePlatforms                         = @();
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @("AdeleV@001q1.onmicrosoft.com");
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @();
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @();
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA100-Admins-BaseProtection-AllApps-AnyPlatform-Block-BlockLegacyAuthentication"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("block");
            ClientAppTypes                           = @("exchangeActiveSync", "other");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA100-Admins-BaseProtection-AllApps-AnyPlatform-Block-BlockLegacyAuthentication";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Breakglass");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "OR";
            Id                                       = "4cd372f4-00e7-46b5-a86e-ff2bc82f98ea";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @("CA-Persona-Admins");
            IncludeLocations                         = @();
            IncludePlatforms                         = @();
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @("AlexW@001q1.onmicrosoft.com");
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @();
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @();
            ManagedIdentity                          = $true
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA102-Admins-IdentityProtection-AllApps-AnyPlatform-MFA-LowAndMediumRiskySignIns"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("mfa");
            ClientAppTypes                           = @("all");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA102-Admins-IdentityProtection-AllApps-AnyPlatform-MFA-LowAndMediumRiskySignIns";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Breakglass");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "OR";
            Id                                       = "152add3b-f152-49dc-90cb-ae4ca63b7947";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @("CA-Persona-Admins");
            IncludeLocations                         = @();
            IncludePlatforms                         = @();
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @("AlexW@001q1.onmicrosoft.com");
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @("medium", "low");
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @();
            ManagedIdentity                          = $true
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA200-Internals-BaseProtection-AllApps-AnyPlatform-Block-BlockLegacyAuthentication"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("block");
            ClientAppTypes                           = @("exchangeActiveSync", "other");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA200-Internals-BaseProtection-AllApps-AnyPlatform-Block-BlockLegacyAuthentication";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Breakglass");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "OR";
            Id                                       = "e89a2538-ccac-49ac-984c-65104ea9c791";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @("CA-Persona-Internals");
            IncludeLocations                         = @();
            IncludePlatforms                         = @();
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @("AlexW@001q1.onmicrosoft.com");
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @();
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @();
            ManagedIdentity                          = $true
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA103-Admins-IdentityProtection-AllApps-AnyPlatform-PwdReset-LowAndMediumRiskyUsers"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("mfa", "passwordChange");
            ClientAppTypes                           = @("all");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA103-Admins-IdentityProtection-AllApps-AnyPlatform-PwdReset-LowAndMediumRiskyUsers";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Breakglass");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "AND";
            Id                                       = "addd1936-7a6e-4732-89e3-d742ace63bb2";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @("CA-Persona-Admins");
            IncludeLocations                         = @();
            IncludePlatforms                         = @();
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @("AlexW@001q1.onmicrosoft.com");
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @();
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @("medium", "low");
            ManagedIdentity                          = $true
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA000-Unspecified-BaseProtection-AllApps-AllPlatforms-Block"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("block");
            ClientAppTypes                           = @("all");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA000-Unspecified-BaseProtection-AllApps-AllPlatforms-Block";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Admins", "CA-Persona-Breakglass", "CA-Persona-Internals", "CA-Persona-ServiceAccounts", "CA-Persona-Guest");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "OR";
            Id                                       = "1cb3af77-e16c-4930-97a2-9bdf7d2e1d5b";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @();
            IncludeLocations                         = @();
            IncludePlatforms                         = @();
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @("All");
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @();
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @();
            ManagedIdentity                          = $true
        }
        AADConditionalAccessPolicy "AADConditionalAccessPolicy-CA202-AppProtection-AllApps-Android-APP"
        {
            ApplicationEnforcedRestrictionsIsEnabled = $False;
            BuiltInControls                          = @("compliantApplication");
            ClientAppTypes                           = @("all");
            CloudAppSecurityIsEnabled                = $False;
            CloudAppSecurityType                     = "";
            CustomAuthenticationFactors              = @();
            DeviceFilterRule                         = "";
            DisplayName                              = "CA202-AppProtection-AllApps-Android-APP";
            Ensure                                   = "Present";
            ExcludeApplications                      = @();
            ExcludeExternalTenantsMembers            = @();
            ExcludeExternalTenantsMembershipKind     = "";
            ExcludeGroups                            = @("CA-Persona-Breakglass");
            ExcludeLocations                         = @();
            ExcludePlatforms                         = @();
            ExcludeRoles                             = @();
            ExcludeUsers                             = @();
            GrantControlOperator                     = "OR";
            Id                                       = "706cc0de-bea0-4753-9209-7e4f528d47b4";
            IncludeApplications                      = @("All");
            IncludeExternalTenantsMembers            = @();
            IncludeExternalTenantsMembershipKind     = "";
            IncludeGroups                            = @("CA-Persona-Internals");
            IncludeLocations                         = @();
            IncludePlatforms                         = @("android");
            IncludeRoles                             = @();
            IncludeUserActions                       = @();
            IncludeUsers                             = @();
            PersistentBrowserIsEnabled               = $False;
            PersistentBrowserMode                    = "";
            SignInFrequencyIsEnabled                 = $False;
            SignInFrequencyType                      = "";
            SignInRiskLevels                         = @();
            State                                    = "enabled";
            TenantId                                 = $OrganizationName;
            UserRiskLevels                           = @();
            ManagedIdentity                          = $true
        }
        AADNamedLocationPolicy "AADNamedLocationPolicy-AllowedCountries"
        {
            CountriesAndRegions               = @("IE", "GB");
            CountryLookupMethod               = "clientIpAddress";
            DisplayName                       = "AllowedCountries";
            Ensure                            = "Present";
            Id                                = "1c258539-1fb4-42a4-a17b-4ba0f668c59e";
            IncludeUnknownCountriesAndRegions = $False;
            OdataType                         = "#microsoft.graph.countryNamedLocation";
            TenantId                          = $OrganizationName;
            ManagedIdentity                   = $true
        }
    }
}

M365TenantConfig #-ConfigurationData .\ConfigurationData.psd1
