#!/usr/bin/env ruby
require 'thor'
require_relative '../src/api.rb'

module Exceptions
  def translate_exceptions method_name
    old_method = instance_method method_name

    define_method method_name do |*args|
      old_method.bind(self).call *args
    end
  rescue API::InvalidCredentialsException
    puts "1"
  rescue API::NoSuchRecord
    puts "2"
  rescue API::RecordValidationException
    puts "3"
  end
end

module SegretoCLI
  class Account < Thor
    extend Exceptions
  
    desc "edit", "Edit a value without password validation"
    option :name
    option :password
    option :email
    def edit
      user = User.find
      
      if options[:name]
        puts "New Name: "
        name = gets.chomp
        user.name = name
      end
      if options[:password]
        puts "New Password: "
        pass = gets.chomp
        user.pass = pass
      end
      if options[:password]
        puts "Confirm New Password: "
        pass_conf = gets.chomp
      end
      if options[:email]
        puts "New Email: "
        email = gets.chomp
        user.email = email
      end
      if options[:password] || options[:email]
        puts "Enter old Password: "
        old = gets.chomp
      end

      user.save
    end
    translate_exceptions :edit
  end
  
# class Recall < Thor
#   extend Exceptions
#   
#   desc "all", "Recall all keys OR key-secret pairs"
#   option :keys
#   def all
#   end
#   translate_exceptions :all
# end
  
  class Segreto < Thor
    extend Exceptions
    
    #Account Management
    desc "register [USER] [PASS] [PASS_CONF]",
         "Register for a new account with Segreto"
    def register(user, pass, pass_conf)
      User.create :username => user, :password => pass, :password_confirmation => pass_conf
    end
    translate_exceptions :register
  
    desc "login [USER] [PASS]", "Login to Segreto"
    def login(user, pass)
      user = User.login user, pass
      Appdata.set :remember_token, user.remember_token
      Appdata.set :username, user
    end
    translate_exceptions :login
  
    desc "account SUBCOMMAND ...ARGS", "Edit/Modify a Segreto Account"
    subcommand "account", Account
  
    #Secret Management
#    desc "recall [SUBCOMMAND] ...ARGS", "Recall Secrets"
#    subcommand "recall", Recall
    desc "recall key", "Recall Secrets"
    def recall(key)
      secret = Secret.find key
      puts "Key:  #{secret["secret"]["key"]}\nValue: #{secret["secret"]["value"]}"
    end
  
    desc "remember [KEY] [SECRET]", "Remember a Secret"
    def remember(key, secret)
      sec = Secret.create key, secret
      recall key
    end
    translate_exceptions :remember
  
    desc "revise [KEY] [SECRET]", "Revise an existing Secret with a new one"
    def revise(key, new_secret)
      sec = Secret.find key
      sec["value"] = new_secret
      sec.save
    end
    translate_exceptions :revise
  
    desc "change [KEY] [SECRET]", "Alias \"revise <key> <new-secret>\""
    def change(key, new_secret)
      revise(key, new_secret)
    end
    translate_exceptions :change
  
    desc "forget [KEY]", "Forget an existing key"
    def forget(key)
      sec = Secret.find key
      puts "Are you sure? y/n"
      ans = gets.chomp
      if ans == "y"
        sec.destroy
      end
    end
    translate_exceptions :forget
  end
end  

SegretoCLI::Segreto.start(ARGV)
