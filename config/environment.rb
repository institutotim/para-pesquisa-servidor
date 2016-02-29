# Construct redis URL and set it to environment
ENV['REDIS_URL'] = ENV['REDIS_PORT'] if !ENV['REDIS_URL'] && ENV['REDIS_PORT']

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
UppServer::Application.initialize!
