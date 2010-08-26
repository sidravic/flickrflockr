module Flickr
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    def acts_as_flickr(options = {})
      cattr_accessor :api_key, :secret
      
      @api_key = options[:api_key] if options[:api_key]
      @secret = options[:secret] if options[:secret]
    end   
  end
    
end