require 'rest-client'
require '../config'

module RequestHelpers
  def url id=nil
    endpoint = Config.get :api_endpoint

    if id
      endpoint + base_route + "/" + id
    else
      endpoint + base_route
    end
  end

  def authenticated_url id=nil
    url(id) + auth_query_string
  end

  private

  def auth_query_string
    username = Config.get :username
    token = Config.get :remember_token
    "?username=#{username}&remember_token=#{token}"
  end

#  def self.parse

  class Deserializer
    def init type, fields
      # set the list of allowable field names
      @type = type
      @fields = fields.map(&:to_s)
    end

    def parse response
      json = JSON.parse response
      unless ok? response.code
        # error?
      else if json.is_a? Array
        json.map { |o| parse_single o }
      else
        parse_single json
      end
    end

    private

    def ok? code
      code.between?(200, 299)
    end

    def parse_single json
      params = {}
      raise FieldLengthMismatchError.new unless json.length == fields.length
      json.each do |k,v|
        raise FieldNameMismatchError.new(k) unless fields.include? k
        params[k.to_sym] = v
      end
      params
    rescue FieldLengthMismatchError
      wrong_fields = json.keys.inject [] do |wrong_fields, k|
        wrong_fields << k unless fields.include? k
        wrong_fields
      end
      FieldMismatchError.new("Unexpected fields found in API response: " + wrong_fields)
    rescue FieldNameMismatchError => e
      FieldMismatchError.new("Unexpected field #{e.message} found in API response.")
    end

    def type
      @type
    end

    def fields
      @fields
    end

    class FieldMismatchError < RuntimeError
    end

    class FieldLengthMismatchError < FieldMismatchError
    end

    class FieldNameMismatchError < FieldMismatchError
    end
  end
end
