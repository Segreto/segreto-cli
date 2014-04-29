require 'rest-client'
#require '../config.rb'

module RequestHelpers
  def url base_route, id=nil
    #endpoint = Config.get :api_endpoint
    endpoint = 'localhost:3000'

    if id
      endpoint + base_route + "/" + id
    else
      endpoint + base_route
    end
  end

  def authenticated_url base_route, id=nil
    url(base_route, id) + auth_query_string
  end

  private

  def auth_query_string
    username = 'md' #Config.get :username
    token = 'a' #Config.get :remember_token
    "?username=#{username}&remember_token=#{token}"
  end
end
