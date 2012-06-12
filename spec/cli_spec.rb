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
      cli_class.should_receive(:hunt_for_meat)
      cli
    end
  end

  context "when finding the meat" do

    context "the Meatfile" do

      it "should find the Meatfile when it's in '.'" do
        File.should_receive(:exists?).with('Meatfile').and_return true
        cli.meatfile.should == 'Meatfile'
      end

      it "should find the Meatfile when it's in '../'"

      it "should find the Meatfile when it's in '/'"

    end

    context "meat locations" do

      it "should find the meat in the MEAT_LOCATIONS"

      it "should return nil if it can't find the meat"

    end

  end

  context "reading the Meatfile" do

    it "should build a new config"

    it "should raise an error if the file is bad"

    it "should raise an error if the file does not contain required config"

    it "should raise an error if the file is not found" do
      File.should_receive(:exists?).and_return false
      lambda { cli }.should raise_error
    end

  end


end
