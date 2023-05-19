module MicrosoftPartnersRestApi

  class FetchData
    attr_reader :config, :body, :client, :access_token, :api_url

    def initialize(body, client = MicrosoftPartnersRestApi.client)
      @config = MicrosoftPartnersRestApi.config
      @api_url = 'https://api.partnercenter.microsoft.com'
      @body = body.symbolize_keys
      @access_token = fetch_access_token
      @client = client
    end

    def fetch
      return invalid_params_response unless (body[:client_id].present? &&
        body[:client_secret].present?) || body[:access_token].present?

      OpenStruct.new(client.format_response(fetch_entity_data))
    end

    def api_call(url)
      client.get_api_data(url, access_token)
    end

    private

    def fetch_access_token
      if body[:access_token].present?
        body[:access_token]
      elsif body[:client_id].present? && body[:client_secret].present?
        options = body.slice(:grant_type, :resource, :client_id, :client_secret)
        options[:resource] = 'https://graph.windows.net'
        response = MicrosoftPartnersRestApi::AccessToken.new(options).fetch
        response.body['access_token']
      end
    end

    def fetch_entity_data
      case body[:entity]
      when 'Customers'
        fetch_customers
      when 'Invoices'
        fetch_invoices
      when 'CustomerBillingProfile'
        fetch_customer_billing_profile(body[:customer_id])
      when 'CustomerAgreements'
        fetch_customer_agreements(body[:customer_id])
      when 'InvoiceLineItems'
        fetch_invoice_line_items(body[:invoice_id])
      when 'CustomerSubscriptions'
        fetch_customer_subscriptions(body[:customer_id])
      when 'CustomerLicenses'
        fetch_customer_licenses(body[:customer_id])
      when 'CustomerUsers'
        fetch_customer_users(body[:customer_id])
      when 'CustomerUserLicenses'
        fetch_customer_user_licenses(body[:customer_id], body[:user_id])
      when 'CustomerLicenseUsage'
        fetch_customer_licenses_usage(body[:customer_id])
      when 'CustomerProducts'
        fetch_customer_products(body[:customer_id], body[:target_view])
      when 'ProductSku'
        fetch_product_sku(body[:product_id], body[:sku_id], body[:country_code])
      when 'SubscriptionAnalytics'
        fetch_subscription_analytics(body[:filter])
      end
    end

    def fetch_customers
      url = api_url + "/v1/customers"
      api_call(url)
    end

    def fetch_invoices
      url = api_url + "/v1/invoices"
      api_call(url)
    end

    def fetch_customer_billing_profile(customer_id)
      return customer_id_not_found unless customer_id.present?

      url = customer_specific_api_url(customer_id, 'profiles/billing')  
      api_call(url)
    end

    def fetch_customer_agreements(customer_id)
      return customer_id_not_found unless customer_id.present?
      
      url = customer_specific_api_url(customer_id, 'agreements')  
      api_call(url)
    end

    def fetch_invoice_line_items(invoice_id)
      return error_response('InvoiceId, Provider, and InvoiceLIneItemType should be present') unless invoice_id.present? &&
        body[:provider].present? && body[:invoicelineitemtype].present?
         
      url = api_url + "/v1/invoices/#{invoice_id}/lineitems?provider=#{body[:provider]}&invoicelineitemtype=#{body[:invoicelineitemtype]}"
      api_call(url)
    end

    def fetch_customer_subscriptions(customer_id)
      return customer_id_not_found unless customer_id.present?
      
      url = customer_specific_api_url(customer_id, 'subscriptions')  
      api_call(url)
    end

    def fetch_customer_licenses(customer_id)
      return customer_id_not_found unless customer_id.present?
      
      url = customer_specific_api_url(customer_id, 'subscribedskus')  
      api_call(url)
    end

    def fetch_customer_users(customer_id)
      return customer_id_not_found unless customer_id.present?
      
      url = customer_specific_api_url(customer_id, 'users')  
      api_call(url)
    end

    def fetch_customer_user_licenses(customer_id, user_id)
      return error_response('CustomerId or UserId is missing') unless customer_id.present? || user_id.present?
      
      url = customer_specific_api_url(customer_id, "users/#{user_id}/licenses")  
      api_call(url)
    end

    def fetch_customer_licenses_usage(customer_id)
      return customer_id_not_found unless customer_id.present?
       
      url = customer_specific_api_url(customer_id, 'analytics/licenses/usage')  
      api_call(url)
    end

    def fetch_customer_products(customer_id, target_view)
      return customer_id_not_found unless customer_id.present?
      return error_response('Invalid target_view') unless valid_target_view_options.include? target_view
      
      url = customer_specific_api_url(customer_id, "products?targetView=#{target_view}")  
      api_call(url)
    end
    
    def fetch_product_sku(product_id, sku_id, country_code)
      return error_response('ProductId, SkuId or CountryCode is missing') unless product_id.present? ||
        country_code.present? || sku_id.present?

      url = api_url + "/v1/products/#{product_id}/skus/#{sku_id}?country=#{country_code}"
      api_call(url)
    end
    
    def fetch_subscription_analytics(filter)
      url = api_url + '/partner/v1/analytics/subscriptions'
      url = url + "?filter=#{filter}" if filter.present?
      api_call(url)
    end

    def customer_id_not_found
      error_response('CustomerId should be present')
    end
    
    def invalid_params_response
      error_response('Invalid params')
    end

    def error_response(message)
      OpenStruct.new({code: 400, body: message})
    end

    def customer_specific_api_url(customer_id, entity_path)
      api_url + "/v1/customers/#{customer_id}/#{entity_path}"
    end

    def valid_target_view_options
      %w[Azure AzureReservations AzureReservationsVM AzureReservationsSQL
        AzureReservationsCosmosDb MicrosoftAzure OnlineServices Software
        SoftwareSUSELinux SoftwarePerpetual SoftwareSubscriptions
        SpecializedOffers
      ]
    end
  end
end