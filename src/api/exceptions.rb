module API
  module Exceptions
    def translate_exceptions method_name
      old_method = instance_method method_name

      define_method method_name do |*args|
        old_method.bind(self).call *args
      end
    rescue RestClient::Forbidden
      raise API::InvalidCredentialsException
    rescue RestClient::ResourceNotFound
      raise API::NoSuchRecord
    rescue RestClient::BadRequest => e
      errors = JSON.parse e.response
      raise API::RecordValidationException.new errors
    end
  end

  class API::Exception < StandardError
  end

  class API::InvalidCredentialsException < API::Exception
  end

  class API::NoSuchRecord < API::Exception
  end

  class API::RecordValidationException < API::Exception
    attr_accessor :errors
    def initialize errors
      self.errors = errors
    end
  end
end
