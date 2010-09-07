module Flickr
  class FlickrConnection
    require "md5"
    require "open-uri"
    FLICKR_URL = "http://flickr.com/services/auth/"
    FLICKR_REST_URL = "http://api.flickr.com/services/rest/"
  
    attr_accessor :api_key, :secret
  
    def initialize(_api_key, _secret)
      @api_key = _api_key 
      @secret = _secret
    end

    def authenticate(options)       
      raise FlickrException::MissingParameterException if options[:api_key].blank? || options[:secret].blank? || options[:perms].blank?
      signature_string = generate_signature_string(options)
      signature = generate_signature(signature_string)
      "#{FLICKR_URL}?api_key=#{options[:api_key]}&perms=#{options[:perms]}&api_sig=#{signature}"
    end
  
    # expects api_key, secret and permission : perms
    # perms could be read/write/delete  # 
    def self.connect_and_authenticate(options = {})
      raise FlickrException::MissingParameterException unless (options[:api_key] && options[:secret])
      raise FlickrException::InvalidParameterException if options[:api_key].blank? || options[:secret].blank?  
      @connection = FlickrConnection.new(options[:api_key], options[:secret])
      [@connection.authenticate(options), @connection]
    end 
    
    def get_token(options)
      raise FlickrException::MissingParameterException unless (options[:api_key] && options[:frob])
      raise FlickrException::InvalidParameterException if options[:api_key].blank?
      options.merge!({:method => "flickr.auth.getToken"})      
      signature_query_string = generate_signature_string(options)
      signature = generate_signature(signature_query_string)
      open("#{FLICKR_REST_URL}" + "?method=#{options[:method]}&api_key=#{options[:api_key]}&frob=#{options[:frob]}&api_sig=#{signature}").read      
    end  
 

  private
   # Expects a hash with parameters such with only symbols for keys as follows
   #      {:method  => "flickr.auth.getToken",
   #      :api_key =>"9a0554259914a86fb9e7eb014e4e5d52", 
   #      :frob => "185-837403740"}   
   def generate_signature_string(_options)
     options = _options.dup
     options.delete(:secret) if options.has_key?(:secret)
     raise FlickrException::InvalidParameterException unless options.instance_of?(Hash)
     raise FlickrException::MissingParameterException if options[:api_key].blank?
     _keys = options.keys.map{|key| key.to_s if key.instance_of?(Symbol) }
     _keys.sort!
     signature_string = "#{self.secret}"
     _keys.each_with_index{|val, index| signature_string += "#{_keys[index]}#{options[_keys[index].to_sym]}"}
     puts signature_string
     signature_string
   end
  
    def generate_signature(signature_string)            
      raise FlickrException::MissingParameterException if signature_string.blank?      
      MD5.hexdigest(signature_string)
    end    
  end
end

#http://localhost:3000/flickr_auth?frob=72157624898115104-e2732eada6d35ed5-49730744