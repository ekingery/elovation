require 'spec_helper'

describe Venue do

  describe "name and address" do
    it "has a name and address" do
      venue = FactoryGirl.create(
        :venue, :name => "Sears Tower", :address => "123 Fake St"
      )
      venue.name.should == "Sears Tower"
      venue.address.should == "123 Fake St"
    end
  end

  describe "validations" do
    context "name" do
      it "must be present" do
        venue = FactoryGirl.build(:venue, :name => nil)

        venue.should_not be_valid
        venue.errors[:name].should == ["can't be blank"]
      end
    end

    context "address" do
      it "must be present" do
        venue = FactoryGirl.build(:venue, :name => "Sears", :address => nil)

        venue.should_not be_valid
        venue.errors[:address].should == ["can't be blank"]
      end
    end
  end

  #todo - delete, verify it deletes the player links

end
