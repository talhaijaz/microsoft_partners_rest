module MicrosoftPartnersRestApi
  class FetchData
    attr_reader :config, :body, :client, :access_token

    def initialize(body, client = MicrosoftPartnersRestApi.client)
      @config = MicrosoftPartnersRestApi.config
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
        response.body['access_token'] rescue ''
      end
    end

    def fetch_entity_data
      if body[:entity] == 'InvoiceLineItems'
        fetch_invoice_line_items(body[:invoice_id])
      elsif body[:entity] == 'Customers'
        client.format_response(fetch_customers)
      elsif body[:entity] == 'Invoices'
        client.format_response(fetch_invoices)
      elsif body[:entity] == 'BillingProfile'
        fetch_billing_profile(body[:customer_id])
      elsif body[:entity] == 'Agreements'
        fetch_agreements(body[:customer_id])
      end
    end

    def fetch_invoice_line_items(invoice_id)
      return {code: 500, body: 'Invalid params'} unless invoice_id.present? &&
        body[:provider].present? && body[:invoicelineitemtype].present?
         
      url = body[:resource] + "/invoices/#{invoice_id}/lineitems?provider=#{body[:provider]}&invoicelineitemtype=#{body[:invoicelineitemtype]}"
      api_response = api_call(url)
      {code: api_response.code, body: (api_response.body['items'] rescue [])}
    end

    def fetch_customers
      url = body[:resource] + "/customers"
      api_call(url)
    end

    def fetch_invoices
      url = body[:resource] + "/invoices"
      api_call(url)
    end

    def fetch_billing_profile(customer_id)
      return {code: 500, body: 'Invalid params'} unless customer_id.present?

      url = body[:resource] + "/customers/#{customer_id}/profiles/billing"
      response = api_call(url)
      {code: response.code, body: (response.body rescue [])}
    end

    def fetch_agreements(customer_id)
      return {code: 500, body: 'Invalid params'} unless customer_id.present?
      
      url = body[:resource] + "/customers/#{customer_id}/agreements"
      response = api_call(url)
      {code: response.code, body: (response.body rescue [])}
     end
  end
end
