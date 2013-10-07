require "spec_helper"

describe Player do
  describe "as_json" do
    it "returns the json representation of the player" do
      player = FactoryGirl.build(:player, :name => "John Doe", :email => "foo@example.com", :twitter => "3E23")

      player.as_json.should == {
        :name => "John Doe",
        :email => "foo@example.com",
        :twitter => "3E23"
      }
    end
  end

  describe "name" do
    it "has a name" do
      player = FactoryGirl.create(:player, :name => "Drew")

      player.name.should == "Drew"
    end
  end

  describe "validations" do
    context "name" do
      it "is required" do
        player = FactoryGirl.build(:player, :name => nil)

        player.should_not be_valid
        player.errors[:name].should == ["can't be blank"]
      end

      it "must be unique" do
        FactoryGirl.create(:player, :name => "Drew")
        player = FactoryGirl.build(:player, :name => "Drew")

        player.should_not be_valid
        player.errors[:name].should == ["has already been taken"]
      end
    end

    context "email" do
      it "must be a valid email format" do
        player = Player.new
        player.email = "invalid-email-address"
        player.should_not be_valid
        player.errors[:email].should == ["is invalid"]
        player.email = "valid@example.com"
        player.valid?
        player.errors[:email].should == []
      end

      it "is required" do
        player = FactoryGirl.build(:player, :name => 'test', :email => nil)
        player.should_not be_valid
        player.errors[:email].should == ["is invalid", "can't be blank"]
      end

      it "must be unique" do
        FactoryGirl.create(
          :player, :name => "Drew", :email => "test@example.com")
        player = FactoryGirl.build(
          :player, :name => "Drew2", :email => "test@example.com")

        player.should_not be_valid
        player.errors[:email].should == ["has already been taken"]
      end
    end

    context "twitter" do
      it "can be blank" do
        player = FactoryGirl.build(
          :player, :name => 'test', :email => "test@abc.com", :twitter => "")
        player.should be_valid
      end

      it "must be a valid twitter address" do
        player = Player.new
        player.twitter = "invalidtwitteraddresstoolong"
        player.should_not be_valid
        player.errors[:twitter].should == ["is invalid"]

        player.twitter = "invalid-char*"
        player.should_not be_valid
        player.errors[:twitter].should == ["is invalid"]

        player.twitter = "3E23"
        player.valid?
        player.errors[:twitter].should == []
      end

      it "strips leading ampersats from twitter handles" do
        player = FactoryGirl.create(
          :player, :name => "Drew", :email => "a@test.com", :twitter => "@3E23")
        player.valid?
        player.errors[:twitter].should == []
        player.twitter.should == "3E23"

        # but does not strip non leading ampersats
        player.twitter = "3@E23"
        player.valid?
        player.errors[:twitter].should ==["is invalid"]
      end

      it "must be unique" do
        FactoryGirl.create(
          :player, :name => "Drew", :email => "a@abc.com", :twitter => "3E23")
        player = FactoryGirl.build(
          :player, :name => "Drew2", :email => "b@abc.com", :twitter => "3E23")
        player.should_not be_valid
        player.errors[:twitter].should == ["has already been taken"]

        # test case sensitivity
        player = FactoryGirl.build(
          :player, :name => "Drew3", :email => "c@abc.com", :twitter => "3e23")
        player.should_not be_valid
        player.errors[:twitter].should == ["has already been taken"]
      end
    end

  end

  describe "recent_results" do
    it "returns 5 of the player's results" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      10.times { FactoryGirl.create(:result, :game => game, :winner => player) }

      player.recent_results.size.should == 5
    end

    it "returns the 5 most recently created results" do
      newer_results = nil
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      Timecop.freeze(3.days.ago) do
        5.times.map { FactoryGirl.create(:result, :game => game, :winner => player) }
      end

      Timecop.freeze(1.day.ago) do
        newer_results = 5.times.map { FactoryGirl.create(:result, :game => game, :winner => player) }
      end

      player.recent_results.sort.should == newer_results.sort
    end

    it "orders results by created_at, descending" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)
      old = new = nil

      Timecop.freeze(2.days.ago) do
        old = FactoryGirl.create(:result, :game => game, :winner => player)
      end

      Timecop.freeze(1.days.ago) do
        new = FactoryGirl.create(:result, :game => game, :winner => player)
      end

      player.recent_results.should == [new, old]
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      player = FactoryGirl.create(:player)
      rating = FactoryGirl.create(:rating, :player => player)
      result = FactoryGirl.create(:result, :winner => player)

      player.destroy

      Rating.find_by_id(rating.id).should be_nil
      Result.find_by_id(result.id).should be_nil
    end
  end

  describe "ratings" do
    describe "find_or_create" do
      it "returns the rating if it exists" do
        player = FactoryGirl.create(:player)
        game = FactoryGirl.create(:game)
        rating = FactoryGirl.create(:rating, :game => game, :player => player)

        expect do
          found_rating = player.ratings.find_or_create(game)
          found_rating.should == rating
        end.to_not change { player.ratings.count }
      end

      it "creates a rating and returns it if it doesn't exist" do
        player = FactoryGirl.create(:player)
        game = FactoryGirl.create(:game)

        expect do
          player.ratings.find_or_create(game).should_not be_nil
        end.to change { player.ratings.count }.by(1)
      end
    end
  end

  describe "rewind_rating!" do
    it "resets the player's rating to the previous rating" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, :game => game, :player => player, :value => 1002)
      FactoryGirl.create(:rating_history_event, :rating => rating, :value => 1001)
      FactoryGirl.create(:rating_history_event, :rating => rating, :value => 1002)

      player.rewind_rating!(game)

      player.ratings.where(:game_id => game.id).first.value.should == 1001
    end
  end

  describe "wins" do
    it "finds wins" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      win = FactoryGirl.create(:result, :game => game, :winner => player)
      loss = FactoryGirl.create(:result, :game => game, :loser => player)
      player.results.for_game(game).size.should == 2
      player.results.for_game(game).wins.should == [win]
    end
  end

  describe "losses" do
    it "finds losses" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      win = FactoryGirl.create(:result, :game => game, :winner => player)
      loss = FactoryGirl.create(:result, :game => game, :loser => player)
      player.results.for_game(game).size.should == 2
      player.results.for_game(game).losses.should == [loss]
    end
  end

  describe "against" do
    it "finds results against a specific opponent" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      opponent1 = FactoryGirl.create(:player)
      opponent2 = FactoryGirl.create(:player)
      win_against_opponent1 = FactoryGirl.create(:result, :game => game, :winner => player, :loser => opponent1)
      loss_against_opponent1 = FactoryGirl.create(:result, :game => game, :winner => opponent1, :loser => player)
      win_against_opponent2 = FactoryGirl.create(:result, :game => game, :winner => player, :loser => opponent2)
      opponent2_game_against_different_player = FactoryGirl.create(:result, :game => game, :winner => FactoryGirl.create(:player), :loser => opponent2)
      player.results.for_game(game).against(opponent1).sort_by(&:id).should == [win_against_opponent1, loss_against_opponent1]
      player.results.for_game(game).against(opponent2).sort_by(&:id).should == [win_against_opponent2]
    end
  end
end
