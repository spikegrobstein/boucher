require './spec/spec_helper'

describe Boucher::MeatGrinder do

  let(:meatgrinder) { Boucher::MeatGrinder.new }

  context "parse_hostname" do
    context "when using the default parser" do

      context "when provided a valid hostname" do
        let(:hostname) { 'app001.prod' }

        context "when using FQDN" do
          let(:fqdn_hostname) { "#{ hostname }.dc.example.com" }

          it "should read the role" do
            meatgrinder.parse_hostname(fqdn_hostname)[:role].should == 'app'
          end

          it "should read the serial" do
            meatgrinder.parse_hostname(fqdn_hostname)[:serial].should == '001'
          end

          it "should read the environment" do
            meatgrinder.parse_hostname(fqdn_hostname)[:environment].should == 'prod'
          end

        end

        context "when using short hostname" do

          it "should read the role" do
            meatgrinder.parse_hostname(hostname)[:role].should == 'app'
          end

          it "should read the serial" do
            meatgrinder.parse_hostname(hostname)[:serial].should == '001'
          end

          it "should read the environment" do
            meatgrinder.parse_hostname(hostname)[:environment].should == 'prod'
          end

        end

      end

      context "when provided an invalid hostname" do

        it "should raise an error if the hostname isn't parsable" do
          lambda { meatgrinder.parse_hostname('app-001') }.should raise_error
        end

      end

    end

    context "when a parser is provided" do
      before do
        meatgrinder.hostname_par
      end
    end
  end

  context "DSL" do
    let(:dsl) { Boucher::MeatGrinder::DSL.new(meatgrinder) }

    context "map_role" do
      it "should map a new role appropriately" do
        meatgrinder.role_map.keys.count.should == 0

        dsl.map_role :app, 'application'

        meatgrinder.role_for(:app).should == 'application'
      end

      it "should not blow up if no role_map is specified" do
        meatgrinder.role_for('app').should == 'app'
      end

      it "should support setting with strings" do
        dsl.map_role 'app', 'application'

        meatgrinder.role_for(:app).should == 'application'
      end

      it "should support getting with strings" do
        dsl.map_role :app, 'application'

        meatgrinder.role_for('app').should == 'application'
      end

      it "should return the default role if a nil role is looked up" do
        dsl.default_role 'generic'

        meatgrinder.role_for(nil).should == 'generic'
      end
    end

    context "map_env" do
      it "should add an environment map" do
        meatgrinder.env_map.keys.count.should == 0

        dsl.map_env :prod, 'production'

        meatgrinder.env_for(:prod).should == 'production'
      end

      it "should not blow up if no env_map is specified" do
        meatgrinder.env_for('production').should == 'production'
      end

      it "should return the default environment if a nil env is looked up" do
        dsl.default_environment 'default'

        meatgrinder.env_for(nil).should == 'default'
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
