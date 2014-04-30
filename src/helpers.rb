module Helpers
  extend self
    
  def login params={}
    puts "..."
    user = User.login params
    puts "Login Successful" if user
  end

  def recall_all
    s = Secret.all
    s.each do |secret|
      puts "Key: #{secret.key}  \tValue: #{secret.value}"
    end
  end

  def recall key
    secret = Secret.find key
    puts "Key: #{secret.key}   \tValue: #{secret.value}"
  end

  def revise key, new_secret
    sec = Secret.find key
    sec.value = new_secret
    sec.save
  end
end
