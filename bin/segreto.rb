#!/usr/bin/env ruby
require "thor"
require "../src/api/secret"
require "../src/api/user"

module SegretoCLI
  class Account < Thor
    desc "edit", "Edit a value without password validation"
    option :name
    option :password
    option :email
    def edit
    end
  end
  
  class Recall < Thor
    desc "all", "Recall all keys OR key-secret pairs"
    option :keys
    def all
    end
  end
  
  class Segreto < Thor
    #Account Management
    desc "register username password password_confirmation",
         "Register for a new account with Segreto"
    def register(user, pass, pass_conf)
      puts "#t"
    end
  
    desc "login username password",
         "Login to Segreto"
    def login(user,pass)
      puts "#t"
    end
  
    desc "account SUBCOMMAND ...ARGS", "Edit/Modify a Segreto Account"
    subcommand "account", Account
  
    #Secret Management
    desc "recall SUBCOMMAND ...ARGS", "Recall Secrets"
    subcommand "recall", Recall
  
    desc "remember key secret", "Remember a Secret"
    def remember(key, secret)
    end
  
    desc "revise key new-secret", "Revise an existing Secret with a new one"
    def revise(key, new_secret)
    end
  
    desc "change key new-secret", "Alias \"revise <key> <new-secret>\""
    def change(key, new_secret)
      revise(key, new_secret)
    end
  
    desc "forget key", "Forget an existing key"
    def forget(key)
    end
  end
end  

SegretoCLI::Segreto.start(ARGV)
