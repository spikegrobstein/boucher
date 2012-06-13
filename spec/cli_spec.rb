require 'boucher'

describe Boucher::CLI do

  let(:hostname) { 'app001.prod' }
  let(:cli_class) { Boucher::CLI.any_instance }
  let(:cli) { Boucher::CLI.new(hostname) }

  context "initializing" do
    before do
      cli_class.stub(:hunt_for_meat => nil)
    end

    it "should set the hostname from the arguments" do
      cli.hostname.should == hostname
    end

    it "should try to find the meat" do
      Boucher::Config.stub(:new => mock(Boucher::Config, :valid? => true))
      Boucher::Blueprint.stub(:new => mock(Boucher::Blueprint))
      Boucher::Meatfile.should_receive(:hunt_for_meat)
      cli
    end
  end

end
