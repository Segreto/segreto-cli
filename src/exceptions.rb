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
