class User < API::Record
  attr_accessor :username, :name, :email, :remember_token

  def initialize params={}
    @username = params[:username]
    @name = params[:name]
    @email = params[:email]
    @remember_token = params[:remember_token]
    super params
  end

  def self.fields
    %w{username email name remember_token}
  end

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
