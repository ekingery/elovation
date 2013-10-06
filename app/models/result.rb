class Result < ActiveRecord::Base
  has_and_belongs_to_many :players
  belongs_to :winner, :class_name => "Player"
  belongs_to :loser, :class_name => "Player"
  belongs_to :game
  has_one :challenge, :dependent => :destroy

  scope :most_recent_first, :order => "created_at desc"
  scope :for_game, lambda { |game| where(:game_id => game.id) }

  validates_presence_of :winner
  validates_presence_of :loser

  validate do |result|
    if result.winner == result.loser and not result.winner.nil?
      errors.add(:base, "Winner and loser can't be the same player")
    end
  end

  def self.find_deletable_for(game)
    most_recent_result_by_player_sql = Result.select("max(results.created_at) as created_at").joins("inner join players_results on results.id = players_results.result_id").where(:game_id => game).group(:player_id).to_sql
    ids = Result.select(:id).joins("inner join (#{most_recent_result_by_player_sql}) x on x.created_at = results.created_at").group(:id).having("count(1) > 1").collect {|i| i.id}
    return Result.find(ids)
  end

  def as_json(options = {})
    {
      :winner => winner.name,
      :loser => loser.name,
      :created_at => created_at.utc.to_s
    }
  end

  def most_recent?
    players.all? do |player|
      player.results.where(:game_id => game.id).order("created_at DESC").first == self
    end
  end
end
