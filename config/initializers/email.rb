file_name = Rails.root.join('config/email.yml')

if File.exists?(file_name)
  email_settings = YAML.load_file(file_name)

  EMAIL_USERNAME = email_settings["username"]
  EMAIL_PASSWORD = email_settings["password"]
  EMAIL_DOMAIN = email_settings["domain"]

  ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => EMAIL_DOMAIN,
    :authentication => :plain,
    :user_name => EMAIL_USERNAME,
    :password => EMAIL_PASSWORD,
    :enable_starttls_auto => true
  }
  
end
