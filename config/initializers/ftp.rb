file_name = Rails.root.join('config/ftp.yml')

if File.exists?(file_name)
  ftp_settings = YAML.load_file(file_name)[Rails.env]

  FTP_HOST = ftp_settings["host"]
  FTP_USERNAME = ftp_settings["user"]
  FTP_PASSWORD = ftp_settings["password"]
end