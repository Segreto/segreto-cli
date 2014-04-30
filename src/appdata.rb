require 'json'

module Appdata
  extend self
  @path = ENV['HOME'] + '/.segreto/config'
  @json = JSON.parse File.open(@path, 'r').read

  def get key
    @json[key.to_s]
  end

  def set key, value
    @json[key.to_s] = value
    File.write @path, JSON.generate(@json)
  end

  def client_key
    File.open(get(:client_key_file), 'r').read
  end
end
