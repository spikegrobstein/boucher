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

  end

end
