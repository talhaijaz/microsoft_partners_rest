module MicrosoftPartnersRestApi

  class FetchData
    attr_reader :config, :body, :client, :access_token, :api_url

    def initialize(body, client = MicrosoftPartnersRestApi.client)
      @config = MicrosoftPartnersRestApi.config
      @api_url = 'https://api.partnercenter.microsoft.com/v1'
      @body = body.symbolize_keys
      @access_token = fetch_access_token
      @client = client
    end

    def fetch
      OpenStruct.new(fetch_entity_data)
    end

    def api_call(url)
      client.get_api_data(url, access_token)
    end

    private

    def fetch_access_token
      if body[:access_token].present?
        body[:access_token]
      else
        options = body.slice(:grant_type, :resource, :client_id, :client_secret)
        options[:resource] = 'https://graph.windows.net'
        response = MicrosoftPartnersRestApi::AccessToken.new(options).fetch
        response.body['access_token']
      end
    end

    def fetch_entity_data
      case body[:entity]
      when 'Customers'
        client.format_response(fetch_customers)
      when 'Invoices'
        client.format_response(fetch_invoices)
      when 'BillingProfile'
        client.format_response(fetch_billing_profile(body[:customer_id]))
      when 'Agreements'
        client.format_response(fetch_agreements(body[:customer_id]))
      when 'InvoiceLineItems'
        client.format_response(fetch_invoice_line_items(body[:invoice_id]))
      end
    end

    def fetch_customers
      url = api_url + "/customers"
      api_call(url)
    end

    def fetch_invoices
      url = api_url + "/invoices"
      api_call(url)
    end

    def fetch_billing_profile(customer_id)
      return customer_id_not_found unless customer_id.present?

      url = api_url + "/customers/#{customer_id}/profiles/billing"
      api_call(url)
    end

    def fetch_agreements(customer_id)
      return customer_id_not_found unless customer_id.present?
      
      url = api_url + "/customers/#{customer_id}/agreements"
      api_call(url)
    end

    def fetch_invoice_line_items(invoice_id)
      return {code: 400, body: 'InvoiceId, Provider, and InvoiceLIneItemType should be present'} unless invoice_id.present? &&
        body[:provider].present? && body[:invoicelineitemtype].present?
         
      url = api_url + "/invoices/#{invoice_id}/lineitems?provider=#{body[:provider]}&invoicelineitemtype=#{body[:invoicelineitemtype]}"
      api_call(url)
    end

    def customer_id_not_found
      {code: 400, body: 'CustomerId should be present'}
    end
  end
end