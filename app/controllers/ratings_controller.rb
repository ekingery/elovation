class RatingsController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @streaks = Result.find_winning_streaks(@game)
  end
end
