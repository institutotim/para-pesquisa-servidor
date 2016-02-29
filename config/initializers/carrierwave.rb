# Production
CarrierWave.configure do |config|
  config.fog_credentials = {provider:             'AWS',
                            aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
                            aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']}

  config.storage        = :fog
  config.fog_use_ssl_for_aws = false
  config.fog_directory  = ENV['AWS_BUCKET']
end

# Dev
if Rails.env.test? or Rails.env.development?
  CarrierWave.configure do |config|
    config.storage           = :file
    config.enable_processing = false
  end
end
