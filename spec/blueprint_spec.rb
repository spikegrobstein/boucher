require 'souce'

describe Souce::Blueprint do

  context "#parse_host" do

    let(:config) do
      Souce::Config.new do
        map_role 'api-app', :api

        map_env :prod, :production

        gateway_server 'admin@192.168.0.1'
        base_domain 'example.com'
        raw_system_address '10.0.1.200'
        nameserver_suffix '2'
        gateway_suffix '1'
        user 'admin'
        chef_server 'chef.example.com'
      end
    end

    let(:role) { 'app' }
    let(:blueprint) { Souce::Blueprint.new(hostname, role, config) }
    let(:hostname) { 'api-app001.prod' }

    it "should read the role" do
      blueprint[:role].should == 'api'
    end

    it "should read the serial" do
      blueprint[:serial].should == '001'
    end

    it "should read the environment" do
      blueprint[:environment].should == 'production'
    end

    it "should read the gateway_server" do
      blueprint[:gateway_server].should == 'admin@192.168.0.1'
    end

    it "should read the base_domain" do
      blueprint[:base_domain].should == 'example.com'
    end

    it "should read the system_address" do
      blueprint[:raw_system_address].should == '10.0.1.200'
    end

    it "should read the gateway_suffix" do
      blueprint[:gateway_suffix].should == '1'
    end

    it "should read the nameserver_suffix" do
      blueprint[:nameserver_suffix].should == '2'
    end

    it "should read the user" do
      blueprint[:user].should == 'admin'
    end

    it "should read the chef_server" do
      blueprint[:chef_server].should == 'chef.example.com'
    end
  end

end
