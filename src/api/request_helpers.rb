require 'open-uri'

module RequestHelpers
  def url base_route, id=nil
    endpoint = Appdata.get :api_endpoint

    if id
      endpoint + base_route + "/" + URI::encode(id)
    else
      endpoint + base_route
    end
  end

  def authenticated_url base_route, id=nil
    url(base_route, id) + auth_query_string
  end

  private

  def auth_query_string
    username = Appdata.get :username
    token = Appdata.get :remember_token
    "?username=#{username}&remember_token=#{token}"
  end
end
