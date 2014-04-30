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
    
    def login params={}
      route = url("#{base_route}/signin?username=#{params[:username]}&password=#{params[:password]}")
      response = RestClient.get route
      response = JSON.parse response
      Appdata.set :username, response[:username]
      Appdata.set :remember_token, response[:remember_token]

      binding.pry
      record = new parse(response)
      record.send(:make_old)
      record
    end

    def logout
      user = Appdata.get :username
      token = Appdata.get :remember_token

      route = url("#{base_route}/signout?username=#{user}&password=#{token}")
      reponse = RestClient.get route
      response = JSON.parse response
      Appdata.set :username, nil
      Appdata.set :remember_token, nil

      response
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
