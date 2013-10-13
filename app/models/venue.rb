class Venue < ActiveRecord::Base
  attr_accessible :address, :description, :name

  has_many :players

  validates :name, :presence => true
  validates :address, :presence => true

  def as_json(options = {})
    {
      :name => name,
      :address => address,
      :description => description
    }
  end

  def all_players
    players.order("name ASC").includes([:venue])
  end
end
