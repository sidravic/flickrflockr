module Flickr
  class FlickrConnection
    require "md5"
    FLICKR_URL = "http://flickr.com/services/auth/"
  
    attr_accessor :api_key, :secret
  
    def initialize(_api_key, _secret)
      @api_key = _api_key 
      @secret = _secret
    end

    def authenticate(options)       
      raise FlickrException::MissingParameterException if options[:api_key].blank? || options[:secret].blank? || options[:perms].blank?
      signature = generate_signature(options)
      "#{FLICKR_URL}?api_key=#{options[:api_key]}&perms=#{options[:perms]}&api_sig=#{signature}"
    end
  
    # expects api_key, secret and permission : perms
    # perms could be read/write/delete  # 
    def self.connect_and_authenticate(options = {})
      raise FlickrException::MissingParameterException if options[:api_key].blank? || options[:secret].blank?
      @connection = FlickrConnection.new(options[:api_key], options[:secret])
      @connection.authenticate(options)
    end  
 
   private
  
    def generate_signature(options = {})            
      raise FlickrException::MissingParameterException if options[:api_key].blank? || options[:secret].blank? || options[:perms].blank?
      signature_string = "#{options[:secret]}api_key#{options[:api_key]}perms#{options[:perms]}"
      MD5.hexdigest(signature_string)
    end
  end
end