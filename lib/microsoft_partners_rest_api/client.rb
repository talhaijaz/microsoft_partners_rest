require 'rest-client'

module MicrosoftPartnersRestApi

  class << self
    attr_accessor :client
  end

  def self.client
    @client ||= Client.new
  end

  class Client
    attr_reader :config, :login_url

    def initialize
      @config = MicrosoftPartnersRestApi.config
      @login_url = 'https://login.microsoftonline.com/'
      yield @config if block_given?
    end

    def oauth_url
     "#{login_url}common/oauth2/authorize?client_id=#{config.client_id}&response_mode=form_post&response_type=code&scope=openid"
    end

    def post_api_data(url, body)
      begin
        response = RestClient.post(url, body)
        OpenStruct.new({ code: response.code, body: JSON(response.body) })
      rescue StandardError => e
        handle_exception(e)
      end
    end
    
    def get_api_data(url, access_token)
      begin
        response = RestClient.get(url, {Authorization: "Bearer #{access_token}"})
        OpenStruct.new({ code: response.code, body: JSON(response.body) })
      rescue StandardError => e
        handle_exception(e)
      end
    end

    def handle_exception(exception)
      OpenStruct.new({ code: exception.http_code, body: 'Invalid params' })
    end

    def format_response(entity_data)
      body = entity_data.body
      body = body['items'] if body['items'].present?
      {code: entity_data.code, body: body}
    end
  end
end
