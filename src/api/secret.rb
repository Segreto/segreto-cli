class Secret < API::Record
  attr_accessor :key, :value

  def initialize params={}
    @key = params[:key]
    @value = params[:value]
    super params
  end

  def self.fields
    %w{key value}
  end

  def to_params
    { key: key, value: value }
  end

  private

  def id
    key
  end
end
