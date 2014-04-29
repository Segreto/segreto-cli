require 'json'

module Appdata
  extend self
  @file ||= File.open 'config.txt', mode='r'
  @json ||= JSON.parse(@file.read)

  def get key
    @json[key.to_s]
  end

  def set key, value
    @json[key.to_s] = value
    File.write 'config.txt', JSON.generate(@json)
  end
end
