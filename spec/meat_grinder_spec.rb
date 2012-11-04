require './spec/spec_helper'

describe Boucher::MeatGrinder do

  let(:meatgrinder) { Boucher::MeatGrinder.new }

  context "DSL" do
    let(:dsl) { Boucher::MeatGrinder::DSL.new(meatgrinder) }


    context "maps" do

      it "should map a new role appropriately" do
        meatgrinder.role_map.keys.count.should == 0

        dsl.map_role :app, 'application'

        meatgrinder.role_for(:app).should == 'application'
      end

      it "should add an environment map" do
        meatgrinder.env_map.keys.count.should == 0

        dsl.map_env :prod, 'production'

        meatgrinder.env_for(:prod).should == 'production'
      end

      it "should support setting with strings" do
        dsl.map_role 'app', 'application'

        meatgrinder.role_for(:app).should == 'application'
      end

      it "should support getting with strings" do
        dsl.map_role :app, 'application'

        meatgrinder.role_for('app').should == 'application'
      end

      it "should not blow up if no env_map is specified" do
        meatgrinder.env_for('production').should == 'production'
      end

      it "should not blow up if no role_map is specified" do
        meatgrinder.role_for('app').should == 'app'
      end

    end

    it "should set the user appropriately" do
      dsl.user 'spike'

      meatgrinder.user.should == 'spike'
    end

    it "should set raw_system_address" do
      dsl.raw_system_address 'raw-node.example.com'

      meatgrinder.raw_system_address.should == 'raw-node.example.com'
    end

    it "should set base_domain" do
      dsl.base_domain 'example.com'

      meatgrinder.base_domain.should == 'example.com'
    end

    it "should set gateway_suffix" do
      dsl.gateway_suffix '11'

      meatgrinder.gateway_suffix.should == '11'
    end

    it "should set nameserver_suffix" do
      dsl.nameserver_suffix '1'

      meatgrinder.nameserver_suffix.should == '1'
    end

    it "should set gateway_server" do
      dsl.gateway_server '10.0.0.1'

      meatgrinder.gateway_server.should == '10.0.0.1'
    end

    it "should set chef_server" do
      dsl.chef_server 'chef.example.com'

      meatgrinder.chef_server.should == 'chef.example.com'
    end

    it "should set cookbook_path" do
      dsl.cookbook_path '/cookbooks'

      meatgrinder.cookbook_path.should == '/cookbooks'
    end

    it "should blow up if a non-existant command is run" do
      lambda { dsl.asdf 'asdf' }.should raise_error
    end

  end

end
