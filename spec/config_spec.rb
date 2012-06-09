require 'souce'
require 'souce/config'

describe Souce::Config do

  context "DSL" do
    let(:dsl) { Souce::Config::DSL.new }
    let(:block) {
      lambda do
        user 'admin'

        map_role :app, :application
        map_role :web, :balancer

        map_env :prod, :production

        raw_system_address '10.3.2.100'

        base_domain 'example.com'
      end
    }

    it "should set the user appropriately" do
      dsl.user 'spike'

      dsl.state[:user].should == 'spike'
    end

    it "should map a new role appropriately" do
      dsl.state[:role_map].keys.count.should == 0

      dsl.map_role :app, 'application'

      dsl.state[:role_map][:app].should == 'application'
    end
  end

  context "#env_for" do

  end

  context "#role_for" do

  end

  context "#get_map" do

    let(:map) do
      { :app => 'application', :db => 'postgres' }
    end

    context "with a symbol" do

      it "should return the right item from the map if it exists" do
        Souce::Config.get_map(:app, map).should == 'application'
      end

      it "should return the item if it does not exist in the map" do
        Souce::Config.get_map(:spike, map).should == 'spike'
      end

    end

    context "with a string" do

      it "should return the right item from the map if it exists" do
        Souce::Config.get_map('app', map).should == 'application'
      end

      it "should return the item if it does not exist in the map" do
        Souce::Config.get_map('spike', map).should == 'spike'
      end

    end

  end

end
