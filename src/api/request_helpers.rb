require 'rest-client'
#require '../config.rb'

module RequestHelpers
  def url base_route, id=nil
    endpoint = Config.get :api_endpoint

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
    username = Config.get :username
    token = Config.get :remember_token
    "?username=#{username}&remember_token=#{token}"
  end
end
