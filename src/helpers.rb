module Helpers
  extend self

  def recall key
    if options[:all]
      Secret.all
    else
      secret = Secret.find key
      puts "Key:  #{secret["secret"]["key"]}\nValue: #{secret["secret"]["value"]}"
    end
  end

  def revise key, new_secret
    sec = Secret.find key
    sec["value"] = new_secret
    sec.save
  end
end
