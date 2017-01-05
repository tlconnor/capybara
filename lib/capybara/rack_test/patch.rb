# frozen_string_literal: true

if RUBY_VERSION=="2.4.0"
  class Rack::Test::Session
    def last_response
      @rack_mock_session.last_response
    end
  end
end