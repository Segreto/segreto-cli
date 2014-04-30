require 'io/console'

module SegretoCLI
  
  class Account < Thor
    desc "edit", "Edit a value without password validation"
    option :name
    option :password
    option :email
    def edit
      user = User.find
      params = {} 
      if options[:name]
        print "New Name: "
        params[:name] = $stdin.gets.chomp
      end
      if options[:password]
        print "New Password: "
        params[:password] = STDIN.noecho(&:gets).chomp
        puts "\n"
      end
      if options[:password]
        print "Confirm New Password: "
        params[:password_confirmation] = STDIN.noecho(&:gets).chomp
        puts "\n"
      end
      if options[:email]
        print "New Email: "
        params[:email] = $stdin.gets.chomp
      end
      if options[:password] || options[:email]
        print "Enter old Password: "
        params[:old_password] = STDIN.noecho(&:gets).chomp
        puts "\n"
      end

      if (options[:password] == nil) && (options[:email] == nil)
        user.unauth_save params
      else
        user.save params
      end
      puts "####################"
      Helpers.view
    end

    desc "view", "View your Segreto Account Details"
    def view
      Helpers.view
    end
  end
  
  class Segreto < Thor
    #Account Management
    desc "account SUBCOMMAND ...ARGS", "Edit/Modify a Segreto Account"
    subcommand "account", Account
  
    desc "login", "Login to Segreto"
    def login
      print "Username: "
      user = $stdin.gets.chomp
      print "Password: "
      pass = STDIN.noecho(&:gets).chomp
      puts "\n"
      Helpers.login username: user, password: pass
    end

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
  
    desc "register",
         "Register for a new account with Segreto"
    def register
      print "Username: "
      user = $stdin.gets.chomp
      print "Password: "
      pass = STDIN.noecho(&:gets).chomp
      puts "\n"
      print "Password Confirmation: "
      pass_conf = STDIN.noecho(&:gets).chomp
      puts "\n"
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

    #Secret Management
    desc "change [KEY]", "Alias \"revise <key> <new-secret>\""
    def change(key)
      print "New value for #{key}: "
      new_secret = $stdin.gets.chomp
      Helpers.revise key, new_secret
    end
  
    desc "forget [KEY]", "Forget an existing key"
    def forget(key)
      sec = Secret.find key
      puts "Are you sure? y/n"
      ans = $stdin.gets.chomp
      if ans == "y"
        sec.destroy
      end
    end

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
      sec = Secret.create key: key, value: secret
      Helpers.recall key
    end
  
    desc "revise [KEY]", "Revise an existing Secret with a new one"
    def revise key
      print "New value for #{key}: "
      new_secret = $stdin.gets.chomp
      Helpers.revise key, new_secret
    end
  end
end  
