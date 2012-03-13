require_relative '../spec_helper.rb'

describe 'The WebServer App' do
  def app
    Sinatra::Application
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello world!'
  end
end