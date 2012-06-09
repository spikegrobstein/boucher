require 'souce'
require 'souce/config'

describe Souce::Config do

  context "DSL" do
    let(:dsl) { Souce::Config::DSL.new }

    it "should set the user appropriately" do
      dsl.user 'spike'

      dsl.state[:user].should == 'spike'
    end

    it "should map a new role appropriately" do
      dsl.state[:role_map].keys.count.should == 0

      dsl.map_role :app, 'application'

      dsl.state[:role_map][:app].should == 'application'
    end

    it "should add an environment map" do
      dsl.state[:env_map].keys.count.should == 0

      dsl.map_env :prod, 'production'

      dsl.state[:env_map][:prod].should == 'production'
    end

    it "should set raw_system_address" do
      dsl.raw_system_address 'raw-node.example.com'

      dsl.state[:raw_system_address].should == 'raw-node.example.com'
    end

    it "should set base_domain" do
      dsl.base_domain 'example.com'

      dsl.state[:base_domain].should == 'example.com'
    end

    it "should set gateway_suffix" do
      dsl.gateway_suffix '11'

      dsl.state[:gateway_suffix].should == '11'
    end

    it "should set nameserver_suffix" do
      dsl.nameserver_suffix '1'

      dsl.state[:nameserver_suffix].should == '1'
    end

    it "should set gateway_server" do
      dsl.gateway_server '10.0.0.1'

      dsl.state[:gateway_server].should == '10.0.0.1'
    end

    it "should set chef_server" do
      dsl.chef_server 'chef.example.com'

      dsl.state[:chef_server].should == 'chef.example.com'
    end

  end

  context "maps" do

    let(:config) do
      Souce::Config.new do
        map_env :prod, 'production'
        map_env :qa, 'preproduction'

        map_role :app, 'rails'
        map_role :web, 'balancer'
      end
    end

    context "#env_for" do

      it "should map an env properly if it is configured" do
        config.env_for(:prod).should == 'production'
      end

      it "should return the passed env if it's not configured" do
        config.env_for(:staging).should == 'staging'
      end

    end

    context "#role_for" do

      it "should map a role properly if it's been configured" do
        config.role_for(:app).should == 'rails'
      end

      it "should map a role properly if it hasn't been configured" do
        config.role_for(:db).should == 'db'
      end

    end

    context "#get_map" do

      let(:map) do
        { :app => 'application', :db => 'postgres' }
      end

      context "with a symbol" do

        it "should return the right item from the map if it exists" do
          config.get_map(:app, map).should == 'application'
        end

        it "should return the item if it does not exist in the map" do
          config.get_map(:spike, map).should == 'spike'
        end

      end

      context "with a string" do

        it "should return the right item from the map if it exists" do
          config.get_map('app', map).should == 'application'
        end

        it "should return the item if it does not exist in the map" do
          config.get_map('spike', map).should == 'spike'
        end

      end

    end
  end

  context "valid?" do

    Souce::Config::REQUIRED_FIELDS.each do |f|
      it "should require #{f}"
    end

  end

end
