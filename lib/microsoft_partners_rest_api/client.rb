require 'rest-client'

module MicrosoftPartnersRestApi

  class << self
    attr_accessor :client

    def client
      @client ||= Client.new
    end
  end

  class Client
    attr_reader :config, :login_url

    def initialize
      @config = MicrosoftPartnersRestApi.config
      @login_url = 'https://login.microsoftonline.com/'
      yield @config if block_given?
    end

    def oauth_url(redirect_uri=nil, response_mode=nil)
     url = "#{login_url}common/oauth2/authorize?client_id=#{config.client_id}&response_type=code&scope=openid,offline_access"
     url = response_mode.nil? ? url : url + "&response_mode=#{response_mode}"
     redirect_uri.nil? ? url : url + "&redirect_uri=#{redirect_uri}"
    end

    def post_api_data(url, body)
      begin
        response = RestClient.post(url, body)
        OpenStruct.new({ code: response.code, body: JSON(response.body) })
      rescue StandardError => e
        handle_exception(e)
      end
    end

    def get_api_data(url, access_token, continuation_token=nil)
      begin
        headers = {Authorization: "Bearer #{access_token}"}
        headers = headers.merge!("MS-ContinuationToken" => continuation_token) if continuation_token.present?
        response = RestClient.get(url, headers)
        OpenStruct.new({ code: response.code, body: JSON(response.body) })
      rescue StandardError => e
        handle_exception(e)
      end
    end

    def handle_exception(exception)
      OpenStruct.new({ code: exception.http_code, body: exception.http_body })
    end

    def format_response(entity_data)
      body = entity_data.body
      {code: entity_data.code, body: body}
    end
  end
end
