require 'rack'

module Rack
  class XSessionID
    def initialize(app, kwargs={})
      header_name = 'X-Session-ID'
      @app = app
      @env_key = "HTTP_#{header_name}".upcase.tr('-', '_')
    end
    def call(env)
      env['HTTP_COOKIE'] = "session_id=#{env[@env_key]}" if env[@env_key]
      @app.call(env)
    end
  end
end