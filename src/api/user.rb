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

  def create params={}
    new(params).save(params)
  end

   def find string
     record = new parse(RestClient.get(url(base_route, id)))
     record.send(:make_old)
     record
   end

  def save params={}
    if new_record? #create
      RestClient.post url(self.class.base_route, id), params
      make_old
    else #update
      url = authenticated_url(self.class.base_route, id)
      RestClient.patch url, to_params 
    end
    self
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
