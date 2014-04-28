require 'rest-client'

require 'request_helpers.rb'

class API::Record
  include RequestHelpers # provides url & authenticated_url

  attr_accessor :base_route

  # init is called at the end of a call to new by default in Ruby
  def init params={}
    # disallow instantiation of the Record abstract class
    if self.class == Record
      # is this the best error type? idk...
      raise NameError.new("Should not instantiate abstract class Record")
    end

    # set the base route for the resource represented by the class
    base_route = params[:base_route]

    # create a deserializer for the class for parsing RestClient responses
    @deserializer = Deserializer.new self.class, params.keys.delete(:base_route)

    @is_new_record = true
  end

  def self.create params={}
    self.new(params).save
  end

  def self.all # we'll need to error here in User - special case
    RestClient.get authenticated_url
  end

  def self.find id # and we'll need to override this in User for no id
    if response = RestClient.get authenticated_url(id)
      record = self.new @deserializer.parse(response)
      record.make_old
      record
    else
      raise Error.new("better error class here for missing record")
    end
  end

  def save
    if new_record? #create
      if RestClient.post authenticated_url, to_params
        make_old
      else
        #error
      end
    else #update
      RestClient.patch authenticated_url(id), to_params 
    end
  end

  def destroy
    RestClient.delete authenticated_url(id)
  end

  # require child class to override to_params for anything to work
  def to_params
    method_missing :to_params
  end

  private

  def id
    method_missing :id
  end

  def new_record?
    @is_new_record
  end

  def make_old
    @is_new_record = false
  end

  def self.from_json json
    self.new @deserializer.parse(json)
  end
end
