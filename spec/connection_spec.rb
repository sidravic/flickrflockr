require File.dirname(__FILE__) + "/../lib/flickrflockr/connection.rb"
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require "md5"

module ConnectionSpecHelper
  API_KEY = "1533d3477c4c35f8b24b8592c4199791"
  SECRET = "4f70d2e8104edaef"
  PERMS = "write"
  
  API_SIGNATURE_STRING = "#{SECRET}api_key#{API_KEY}perms#{PERMS}"
  FLICKR_REST_URL = "http://api.flickr.com/services/rest/"
  FLICKR_URL = "http://flickr.com/services/auth/"
  SIGNATURE = MD5.hexdigest(API_SIGNATURE_STRING)  
  REDIRECTION_URL = "#{FLICKR_URL}?api_key=#{API_KEY}&perms=#{PERMS}&api_sig=#{SIGNATURE}"
end

describe Flickr::FlickrConnection do
  include ConnectionSpecHelper
  
  before(:each) do
    
    @options = {:api_key => ConnectionSpecHelper::API_KEY, 
                :secret => ConnectionSpecHelper::SECRET,
                :perms => ConnectionSpecHelper::PERMS}
                
    @connection = Flickr::FlickrConnection.new(options[:api_key], options[:secret])
    @connection.api_key = @options[:api_key]
    @connection.secret = @options[:secret]    
    
    Flickr::FlickrConnection.stub!(:connect_and_authenticate).with(@options).and_return(@connection)
    
    @frob = {:frob => "72157624898115104-e2732eada6d35ed5-49730744"}  
    @flickr_auth_gettoken = {:method => "flickr.auth.getToken"}
    @signature_string = "4f70d2e8104edaefapi_key1533d3477c4c35f8b24b8592c4199791frob185-837403740methodflickr.auth.getToken"                       
    @get_token_signature = "b5a6b52decf5e48d76da23c01c4b580d"
    @get_token_signature_string = "4f70d2e8104edaefapi_key1533d3477c4c35f8b24b8592c4199791frob72157624898115104-e2732eada6d35ed5-49730744methodflickr.auth.getToken"
    @frob_response_xml = File.read(RAILS_ROOT + "/spec/feeds/glickr_getToken.xml")
    
  end
  
  it "should return a new connection object on connect_and_authenticate" do
    connection = Flickr::FlickrConnection.connect_and_authenticate(@options)
    connection.api_key.should_not be_nil
    connection.secret.should_not be_nil     
  end
  
  it "should generate the token from frob" do
    require 'open-uri'
    @options.delete(:secret)
    @options.delete(:perms)
    @options.merge!(@frob)
    @options.merge!(@flickr_auth_gettoken)    
    options = @options
    string = @get_token_signature_string
    @connection.instance_eval { generate_signature_string options }.should eql(@get_token_signature_string)
    @connection.instance_eval { generate_signature string}.should eql(@get_token_signature)     
  end
  
  it "should return the signature string" do  
    signature_string = @signature_string
    @connection.instance_eval{  generate_signature signature_string }.should eql("ff302539e1ce92e676d75eaac86b59e0")    
  end
  
  it "should return the redirection url on authentication" do    
    @connection.authenticate(@options).should eql(ConnectionSpecHelper::REDIRECTION_URL)
  end 


  
end


