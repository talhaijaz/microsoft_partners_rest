module MicrosoftPartnersRestApi
  class FetchData
    attr_reader :config, :body

    def initialize(body, client = MicrosoftPartnersRestApi.client)
      @config = MicrosoftPartnersRestApi.config
      @body = body.symbolize_keys
    end

    def fetch
      sub_url = compose_url(body)
      if sub_url.nil?
        return OpenStruct.new({ code: 433, body: 'Invalid Resource' })
      end
      url = body[:api_url] + "/v1/#{sub_url}"
      begin
        response = RestClient.get(url, {Authorization: "Bearer #{body[:access_token]}"})
        OpenStruct.new({ code: response.code, body: JSON(response.body) })
      rescue StandardError => e
        handle_exception(e)
      end
    end

    def handle_exception(exception)
      OpenStruct.new({ code: exception.http_code, body: exception.as_json })
    end

    private

    def compose_url(body)
      if body[:entity] == 'Customerlicenses'
          "customers/#{body[:customer_id]}/analytics/licenses/usage" if body[:customer_id].present?
        elsif body[:entity] == 'PartnerLicenses'
          'analytics/licenses/usage'
        elsif body[:entity] == 'Customers'
          'customers'
        end
    end 
  end
end
