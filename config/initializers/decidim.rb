Decidim.configure do |config|
  config.available_locales = %i[cz en pl]
  config.default_locale = :pl
  config.sms_gateway_service = "Decidim::Verifications::Sms::Gateway"
end
