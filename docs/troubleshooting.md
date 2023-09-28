# Troubleshooting

## Data Factory

### Pipelines fail with the following error:
Error: invalid_client, Error Message: AADSTS7000222: The provided client secret keys for app '289799f1-c9e6-4683-8d41-78a83d6fb7f7' are expired

The client secret stored in the Azure Keyvault has expired.  You will need to generate a new client secret for the App Registration and then refresh the value of the secret in Key Vault.
