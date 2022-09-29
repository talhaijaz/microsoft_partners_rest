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
  end
end
