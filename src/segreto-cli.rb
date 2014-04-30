module SegretoCLI
  
  class Account < Thor
    extend Exceptions
  
    desc "edit", "Edit a value without password validation"
    option :name
    option :password
    option :email
    def edit
      user = User.find
      params = {} 
      if options[:name]
        puts "New Name: "
        params[:name] = gets.chomp
      end
      if options[:password]
        puts "New Password: "
        params[:password] = gets.chomp
      end
      if options[:password]
        puts "Confirm New Password: "
        params[:password_confirmation] = gets.chomp
      end
      if options[:email]
        puts "New Email: "
        params[:email] = gets.chomp
      end
      if options[:password] || options[:email]
        puts "Enter old Password: "
        params[:old_password] = gets.chomp
      end

      user.save params
    end
    translate_exceptions :edit
  end
  
  class Segreto < Thor
    extend Exceptions

    #Account Management
    desc "account SUBCOMMAND ...ARGS", "Edit/Modify a Segreto Account"
    subcommand "account", Account
  
    desc "login [USER] [PASS]", "Login to Segreto"
    def login(user, pass)
      Helpers.login username: user, password: pass
    end
    translate_exceptions :login

    desc "logout", "Logout of Segreto"
    def logout
      user = Appdata.get :username
      token = Appdata.get :remember_token
      if (user == nil) || (token == nil)
        Appdata.set :username, nil
        Appdata.set :remember_token, nil
        puts "Already Logged Out"
      else
        response = User.logout user, token
        if response
          puts "Successfully Logged Out."
        end
      end
    end
  
    desc "register [USER] [PASS] [PASS_CONF]",
         "Register for a new account with Segreto"
    def register(user, pass, pass_conf)
      u = User.create :username => user, 
                         :password => pass, 
                         :password_confirmation => pass_conf
      if u
        puts "Registration successful. Welcome, #{u.username}!"
        puts "Please wait while we log you in."
        Helpers.login username: user, password: pass
      else
        puts "Registration unsuccessful."
      end
    end
    translate_exceptions :register
  
    #Secret Management
    desc "change [KEY] [SECRET]", "Alias \"revise <key> <new-secret>\""
    def change(key, new_secret)
      Helpers.revise key, new_secret
    end
    translate_exceptions :change
  
    desc "forget [KEY]", "Forget an existing key"
    def forget(key)
      sec = Secret.find key
      puts "Are you sure? y/n"
      ans = $stdin.gets.chomp
      if ans == "y"
        sec.destroy
      end
    end

    translate_exceptions :forget
    desc "recall key", "Recall Secrets"
    option :all
    def recall(key=nil)
      if options[:all]
        Helpers.recall_all
      else
        Helpers.recall key
      end
    end
  
    desc "remember [KEY] [SECRET]", "Remember a Secret"
    def remember(key, secret)
      sec = Secret.create key: key, value: secret, plaintext: true
      Helpers.recall key
    end
    translate_exceptions :remember
  
    desc "revise [KEY] [SECRET]", "Revise an existing Secret with a new one"
    def revise(key, new_secret)
      Helpers.revise key, new_secret
    end
    translate_exceptions :revise
  end
end  
