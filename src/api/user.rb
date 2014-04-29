class User < API::Record
  attr_accessor :username, :name, :email, :remember_token

  class << self
    def create params={}
      new parse(RestClient.post(url(base_route), params))
    end
    translate_exceptions :create

    def find
      record = new parse(RestClient.get(authenticated_url(base_route)))
      record.send(:make_old)
      record
    end
    translate_exceptions :find

    def fields
      %w{username email name remember_token}
    end
  end

  def initialize params={}
    @username = params[:username]
    @name = params[:name]
    @email = params[:email]
    @remember_token = params[:remember_token]
    super params
  end

  def save params={}
    url = authenticated_url(self.class.base_route, id)
    RestClient.patch url, to_params.merge(params)
  end
  translate_exceptions :save

  def to_params
    { username: username,
      name: name,
      email: email,
      remember_token: remember_token
    }
  end

  private

  # only one user at a time, so no id is necessary in the API
  def id
    nil
  end
end
