require "spec_helper"

describe VenuesController do
  describe "new" do
    it "exposes a new venue" do
      get :new

      assigns(:venue).should_not be_nil
    end
  end

  describe "edit" do
    it "exposes the venue for editing" do
      venue = FactoryGirl.create(:venue)

      get :edit, :id => venue

      assigns(:venue).should == venue
    end
  end

  describe "create" do
    context "with valid params" do
      it "creates a venue" do
        post :create, :venue => {
          :name => "Sears Tower", :address => "123 Fake St"
        }

        Venue.where(:name => "Sears Tower").first.should_not be_nil
      end

      it "redirects to the venue's show page" do
        post :create, :venue => 
          {:name => "Sears Tower", :address => "123 Fake St"}

        venue = Venue.where(:name => "Sears Tower").first

        response.should redirect_to(venue_path(venue))
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          post :create, :venue => {:created_at => 3.days.ago, 
            :name => "Sears Tower", :address => "123 Fake St"}

          venue = Venue.where(:name => "Sears Tower").first
          venue.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders new given invalid params" do
        post :create, :venue => {:name => nil}

        response.should render_template(:new)
      end
    end
  end

  #describe "destroy" do
    #it "allows deleting venues without players" do
      #venue = FactoryGirl.create(:venue, :name => "First name")
#
      #delete :destroy, :id => venue
#
      #response.should redirect_to(dashboard_path)
      #Venue.find_by_id(venue.id).should be_nil
    #end

    #it "doesn't allow deleting venues with players" do
      #venue = FactoryGirl.create(:venue, :name => "First name")
      #FactoryGirl.create(:result, :venue => venue)

      #delete :destroy, :id => venue

      #response.should redirect_to(dashboard_path)
      #Venue.find_by_id(venue.id).should == venue
    #end
  #end

  describe "update" do
    context "with valid params" do
      it "redirects to the venue's show page" do
        venue = FactoryGirl.create(
          :venue, :name => "Sears Tower", :address => "123 Fake St"
        )

        put :update, :id => venue, :venue => 
          {:name => "Second name", :address => "321 Real St"}

        response.should redirect_to(venue_path(venue))
      end

      it "updates the venue with the provided attributes" do
        venue = FactoryGirl.create(
          :venue, :name => "Sears Tower", :address => "123 Fake St"
        )

        put :update, :id => venue, :venue => {:name => "Willis Tower"}

        venue.reload.name.should == "Willis Tower"
      end

      it "protects against mass assignment" do
        Timecop.freeze(Time.now) do
          venue = FactoryGirl.create(:venue, :name => "Sears Tower")

          put :update, :id => venue, :venue => {:created_at => 3.days.ago}

          venue.created_at.should > 3.days.ago
        end
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        venue = FactoryGirl.create(
          :venue, :name => "Sears Tower", :address => "123 Fake St"
        )

        put :update, :id => venue, :venue => {:name => nil}

        response.should render_template(:edit)
      end
    end
  end

  describe "show" do
    it "exposes the venue" do
      venue = FactoryGirl.create(:venue)

      get :show, :id => venue

      assigns(:venue).should == venue
    end

    it "returns a json response" do
      Timecop.freeze(Time.now) do
        venue = FactoryGirl.create(:venue)

        #player1 = FactoryGirl.create(:player)
        #player2 = FactoryGirl.create(:player)

        get :show, :id => venue, :format => :json

        json_data = JSON.parse(response.body)
        json_data.should == {
          "name" => venue.name,
          "address" => venue.address,
          "description" => venue.description
        }
      end
    end
  end
end
