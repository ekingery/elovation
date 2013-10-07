class VenuesController < ApplicationController
  include ParamsCleaner

  allowed_params :venue => [:name, :address, :description]

  before_filter :_find_venue, :only => [:destroy, :edit, :show, :update]

  def create
    @venue = Venue.new(clean_params[:venue])

    if @venue.save
      redirect_to venue_path(@venue)
    else
      render :new
    end
  end

  def destroy
    @venue.destroy # if @venue.results.empty? #todo - potentially check players?
    redirect_to dashboard_path
  end

  def edit
  end

  def new
    @venue = Venue.new
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render :json => @venue
      end
    end
  end

  def update
    if @venue.update_attributes(clean_params[:venue])
      redirect_to venue_path(@venue)
    else
      render :edit
    end
  end

  def _find_venue
    #@venue = Venue.includes(:players).where(:id =>params[:id]).first
    @venue = Venue.where(:id =>params[:id]).first
  end
end
