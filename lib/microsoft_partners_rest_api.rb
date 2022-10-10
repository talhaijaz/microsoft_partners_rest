require 'microsoft_partners_rest_api/version'
require 'microsoft_partners_rest_api/config'
require 'microsoft_partners_rest_api/client'
require 'microsoft_partners_rest_api/access_token'
require 'microsoft_partners_rest_api/fetch_data'

module MicrosoftPartnersRestApi
  class Error < StandardError
    def initialize(msg)
      # extract Rest Exception message if present
      if msg.include?('[RestException:')
        msg = msg[/\[RestException:(.*?)\]/, 1]&.strip
      end

      super(msg)
    end
  end
end