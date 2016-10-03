# config/initializers/load_google_analytics_settings.rb
GOOGLE_ANALYTICS_SETTINGS = HashWithIndifferentAccess.new

config = YAML.load_file(Rails.root.join("config", "google_analytics_settings.yml"))[Rails.env]
if config
  GOOGLE_ANALYTICS_SETTINGS.update(config)
end
