require 'boucher/meatfile'

describe Boucher::Meatfile do

  context "when finding the meat" do

    context "the Meatfile" do

      it "should find the Meatfile when it's in '.'" do
        File.should_receive(:exists?).with('Meatfile').and_return true

        Boucher::Meatfile.hunt_for_meat.should == Boucher::Meatfile::MEATFILE_NAME
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
      lambda { Boucher::Meatfile.hunt_for_meat }.should raise_error(Boucher::Meatfile::NotFound)
    end

  end

end
