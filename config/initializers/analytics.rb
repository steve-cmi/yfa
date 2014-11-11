file_name = Rails.root.join('config/analytics.yml')

if File.exists?(file_name)
  analytics_settings = YAML.load_file(file_name)[Rails.env]
  GA_ACCOUNT = analytics_settings["account_id"]
end
