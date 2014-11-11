file_name = Rails.root.join('config/aws.yml')

if File.exists?(file_name)
  # load the libraries
  require 'aws'

  # log requests using the default rails logger
  AWS.config(:logger => Rails.logger)

  # load credentials from a file
  AWS.config(YAML.load(File.read(file_name)))
end
