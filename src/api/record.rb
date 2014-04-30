require File.dirname(__FILE__) + '/request_helpers.rb'
require File.dirname(__FILE__) + '/exceptions.rb'

module API
  class Record
    include RequestHelpers # provides url & authenticated_url
    extend API::Exceptions

    class << self
      include RequestHelpers
      extend API::Exceptions

      def create params={}
        new(params).save
      end

      # we'll need to error here in User - special case
      def all
        response = RestClient.get authenticated_url(base_route+'s')
        parse(response).map do |params|
          record = new params
          record.send(:make_old)
          record
        end
      end
      translate_exceptions :all

      # and we'll need to override this in User for no id
      def find id
        record = new parse(RestClient.get(authenticated_url(base_route, id)))
        record.send(:make_old)
        record
      end
      translate_exceptions :find

      def parse response
        json = JSON.parse response
        if json.is_a? Array
          json.map { |o| parse_single o }
        else
          parse_single json[to_s.downcase]
        end
      end

      def fields
        # override this to return an array of strings naming the acceptable 
        # fields for the record type.
        method_missing :fields
      end

      def base_route
        '/' + self.to_s.downcase
      end

      private

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
        FieldMismatchError.new("Unexpected fields found in API response: " + wrong_fields.join(', '))
      rescue FieldNameMismatchError => e
        FieldMismatchError.new("Unexpected field #{e.message} found in API response.")
      end

      class FieldMismatchError < RuntimeError
      end

      class FieldLengthMismatchError < FieldMismatchError
      end

      class FieldNameMismatchError < FieldMismatchError
      end
    end

    def initialize params={}
      # disallow instantiation of the Record abstract class
      if self.class == Record
        # is this the best error type? idk...
        raise NameError.new("Should not instantiate abstract class Record")
      end

      @is_new_record = true
    end

    def save params={}
      if new_record? #create
        RestClient.post authenticated_url(self.class.base_route), to_params
        make_old
      else #update
        url = authenticated_url(self.class.base_route, id)
        RestClient.patch url, to_params 
      end
      self
    end
    translate_exceptions :save

    def destroy
      RestClient.delete authenticated_url(self.class.base_route, id)
      refresh
      self
    end
    translate_exceptions :destroy

    # require child class to override to_params for anything to work
    def to_params
      method_missing :to_params
    end

    private

    def id
      # override this to alias to the record-type's key field
      method_missing :id
    end

    def new_record?
      @is_new_record
    end

    def make_old
      @is_new_record = false
    end

    def refresh
      @is_new_record = true
    end
  end
end
