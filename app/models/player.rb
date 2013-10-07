class Player < ActiveRecord::Base
  has_many :ratings, :order => "value DESC", :dependent => :destroy do
    def find_or_create(game)
      where(:game_id => game.id).first || create(:game => game, :value => Rating::DefaultValue, :pro => false)
    end
  end

  has_and_belongs_to_many :results do
    def against(opponent)
      player = proxy_association.owner.id
      where(
        [
          "(winner_id = ? and loser_id = ?) OR (winner_id = ? and loser_id = ?)",
          player, opponent, opponent, player
        ]
      )
    end

    def losses
      where(:loser_id => proxy_association.owner.id)
    end

    def wins
      where(:winner_id => proxy_association.owner.id)
    end
  end

  before_destroy do
    results.each { |result| result.destroy }
  end

  validates :name, :uniqueness => true, :presence => true
  validates :email, :uniqueness => true, :format => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, :presence => true
  validates :twitter, :uniqueness => {:case_sensitive => false}, 
    :format => /^[A-Za-z0-9_]{1,15}$/i, :allow_blank => true

  # strip leading ampersat if the user entered one, pre-validation
  def twitter=(value)
    value.gsub!(/^\@/, '')
    write_attribute(:twitter, value)
  end

  def as_json
    {
      :name => name,
      :email => email,
      :twitter => twitter,
    }
  end

  def recent_results
    results.order("created_at DESC").limit(5).includes([:players, :winner, :loser, :game])
  end

  def rewind_rating!(game)
    rating = ratings.where(:game_id => game.id).first
    rating.rewind!
  end
end
