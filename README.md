# MicrosoftPartnersRestApi
Welcome to a ruby client that interacts with the Microsoft partners API.

Comments, PR's are more than welcome. I would love to hear any ideas or suggestions.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'microsoft_partners_ruby'
```

And then execute:
```bash
$ bundle
```
## Usage
This plugin supports both App only and App + User authentication.

1. To setup the partner for authentication follow steps mentioned in this Documentation
https://learn.microsoft.com/en-us/partner-center/develop/partner-center-authentication.

2. After step 1 you will have client_id and client_secret.

3. For app + user authentication Get the oauth url through this call
PartnersRestClient.new(client_id).fetch_oauth_url.

4. Call the acccess Token Api with these params

        params = {grant_type: 'authorization_code',
                  resource: 'https://api.partnercenter.microsoft.com',
                  client_id: 'client_id',
                  client_secret: 'client_secret',
                  tenant_id: 'tenant_id',
                  code: 'Code obtained from step 3'}

    PartnersRestClient.new(params).fetch_access_token

5. You can fetch the data from these 5 entities 
Customers, Invoices, InvoiceLineItems, BillingProfile, Agreements for now like this.
  
        params = {access_token: 'access token fetched from Step 4',
                  resource: 'https://api.partnercenter.microsoft.com',
                  entity: 'InvoiceLineItems',
                  customer_id: 'Your customer id'}

        PartnersRestClient.new(params).fetch_microsft_data

6. For data fetching through app only authentication you jist need to call the api like this.

        params = {grant_type: 'client_credentials'
                  resource: 'https://api.partnercenter.microsoft.com',
                  client_id: 'client_id',
                  client_secret: 'client_secret',
                  tenant_id: 'tenant_id',
                  entity: 'Customers'}

        PartnersRestClient.new(params).fetch_microsft_data

## Note
1. For InvoiceLineItems Entity invoice_id, provider and invoicelineitemtype are required fields and can be sent in params.

2. For Agreements and BillingProfile customer_id is required and can be sent in params.