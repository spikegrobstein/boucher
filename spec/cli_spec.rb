require 'boucher'

describe Boucher::CLI do

  let(:hostname) { 'app001.prod' }
  let(:cli) { Boucher::CLI.new(hostname) }

  context "initializing" do
    before do
      Boucher::CLI.stub(:hunt_for_meat => nil)
    end

    it "should set the hostname from the arguments" do
      cli.hostname.should == hostname
    end

    it "should try to find the meat" do
      Boucher::Meatfile.should_receive(:hunt_for_meat).and_return('Meatfile')
      cli
    end
  end

end
