# frozen_string_literal: true

module Decidim
  module Verifications
    module Sms
      class Gateway
        BLOCKED_COUNTRY_CODES = (ENV["BLOCKED_COUNTRY_CODES"] || "")
                                  .split(",")
                                  .map(&:strip)
                                  .uniq
                                  .freeze

        attr_reader :mobile_phone_number, :code, :context, :parsed_number

        def initialize(mobile_phone_number, code, context = {})
          @parsed_number = Phonelib.parse(mobile_phone_number)
          @mobile_phone_number = parsed_number.e164
          @code = code
          @context = context
        end

        def deliver_code
          return log_and_fail("Invalid phone number") unless parsed_number.valid?
          return log_and_fail("Not a mobile number") unless parsed_number.types.include?(:mobile)
          return log_and_fail("Blocked country") if blacklisted_country?

          uri = URI.parse("https://api.smsapi.pl/sms.do")

          request = Net::HTTP::Post.new(uri)
          request["Authorization"] = "Bearer #{smsapi_token}"
          request.set_form_data(
            "to" => mobile_phone_number,
            "message" => text
          )

          req_options = { use_ssl: uri.scheme == "https" }

          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end

          if response.is_a?(Net::HTTPSuccess) && response.body.start_with?("OK")
            true
          else
            Rails.logger.error("SMSAPI Error: #{response.body}")
            false
          end
        rescue => e
          Rails.logger.error("Error: #{e.message}")
          false
        end

        private

        def smsapi_token
          Rails.application.credentials.dig(:smsapi, :token) || raise("Missing SMSAPI token")
        end

        def blacklisted_country?
          BLOCKED_COUNTRY_CODES.include?(parsed_number.country_code)
        end

        def log_and_fail(message)
          Rails.logger.warn("SMS blocked: #{message}")
          false
        end

        def text
          I18n.t("sms.authorizations.create.text", code: code)
        end
      end
    end
  end
end
