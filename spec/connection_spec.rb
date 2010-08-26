require File.dirname(__FILE__) + "/../lib/flickrflockr/connection.rb"
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require "md5"

module ConnectionSpecHelper
  API_KEY = "1533d3477c4c35f8b24b8592c4199791"
  SECRET = "4f70d2e8104edaef"
  PERMS = "write"
  
  API_SIGNATURE_STRING = "#{SECRET}api_key#{API_KEY}perms#{PERMS}"
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
  end
  
  it "should return a new connection object on connect_and_authenticate" do
    connection = Flickr::FlickrConnection.connect_and_authenticate(@options)
    connection.api_key.should_not be_nil
    connection.secret.should_not be_nil     
  end
  
  it "should return the signature string" do
    options = @options
    @connection.instance_eval{  generate_signature options }.should eql(ConnectionSpecHelper::SIGNATURE)    
  end
  
  it "should return the redirection url on authentication" do    
    @connection.authenticate(@options).should eql(ConnectionSpecHelper::REDIRECTION_URL)
  end
   
  
   

  


  
end
