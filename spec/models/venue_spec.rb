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

  describe "players" do
    it "should respond to players" do
      venue = Venue.new
      venue.should respond_to(:players)
    end
    it "should return the name of a related player" do
      venue = Venue.new
      venue.name = "Sears Tower"
      player1 = Player.new
      player1.venue = venue
      player1.venue.name.should == "Sears Tower"
    end

    it "orders all players by name, descending" do
      venue = FactoryGirl.create(:venue)
      player4 = FactoryGirl.create(:player, :name => "darren", :venue => venue)
      player3 = FactoryGirl.create(:player, :name => "carla", :venue => venue)
      player2 = FactoryGirl.create(:player, :name => "bob", :venue => venue)
      player1 = FactoryGirl.create(:player, :name => "andy", :venue => venue)

      venue.all_players.should == [
        player1,
        player2,
        player3,
        player4,
      ]
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

end
