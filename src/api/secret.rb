require 'base64'

require './appdata.rb'

class Secret < API::Record
  attr_accessor :key
  attr_reader :encrypted_value

  def initialize params={}
    @key = params[:key]

    @cipher = OpenSSL::Cipher::AES.new 256, :CBC

    if params[:plaintext]
      self.client_iv = params[:client_iv] || generate_iv
      self.value = params[:value]
    else
      @client_iv = params[:client_iv]
      @encrypted_value = params[:value]
    end

    params.delete(:plaintext)
    super params
  end

  def client_iv
    Base64.decode64 @client_iv
  end

  def client_iv= iv
    @client_iv = Base64.encode64 iv
    iv
  end

  def value
    @cipher.reset.decrypt
    @cipher.key = Appdata.client_key
    @cipher.iv = client_iv

    ciphertext = Base64.decode64 @encrypted_value
    @cipher.update(ciphertext) + @cipher.final
  end

  def value= value
    @cipher.reset.encrypt
    @cipher.key = Appdata.client_key
    @cipher.iv = client_iv

    ciphertext = @cipher.update(value) + @cipher.final
    @encrypted_value = Base64.encode64 ciphertext
    value
  end

  def self.fields
    %w{key value client_iv}
  end

  def to_params
    { key: key, value: encrypted_value, client_iv: @client_iv }
  end

  private

  def generate_iv
    @cipher.reset.encrypt.random_iv
  end

  def id
    key
  end
end
