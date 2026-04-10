Decidim.configure do |config|
  config.available_locales = %i[en pl cz]
  config.default_locale = :pl
  config.sms_gateway_service = "Decidim::Verifications::Sms::Gateway"
end
