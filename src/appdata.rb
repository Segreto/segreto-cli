require 'json'

module Appdata
  extend self
  @path = ENV['HOME'] + '/.segreto'
  @json = JSON.parse File.open(@path, 'r').read

  def get key
    @json[key.to_s]
  end

  def set key, value
    @json[key.to_s] = value
    File.write @path, JSON.generate(@json)
  end
end
