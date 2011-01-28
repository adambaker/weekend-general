class VenuesController < ApplicationController
  respond_to :html #, :xml, :json
  
  before_filter :authenticate, except: [:index, :show]
  before_filter :fetch_venue, except: [:index, :new, :create]
  before_filter :check_rank, only: [:edit, :update, :destroy]
  
  # GET /venues
  # GET /venues.xml
  def index
    @venues = Venue.order :name  
    respond_with @venues
  end

  # GET /venues/1
  # GET /venues/1.xml
  def show
    respond_with @venue
  end

  # GET /venues/new
  # GET /venues/new.xml
  def new
    @venue = Venue.new(city: Settings::city)
    respond_with @venue
  end

  # POST /venues
  # POST /venues.xml
  def create
    @venue = Venue.new(params[:venue])
    @venue.created_by = current_user.id
    
    respond_to do |format|
      if @venue.save
        flash[:success] = current_theme 'venues', 'new'
        format.html { redirect_to @venue }
        #format.xml  { render :xml => @venue, 
          #:status => :created, :location => @venue }
      else
        format.html { render :action => "new" }
        #format.xml  { render :xml => @venue.errors, 
          #:status => :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.xml
  def update
    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        flash[:success] = current_theme 'venues', 'updated'
        format.html { redirect_to @venue }
        #format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        #format.xml  { render :xml => @venue.errors, :status
          #=> :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.xml
  def destroy
    @venue.destroy

    respond_to do |format|
      flash[:success] = current_theme 'venues', 'deleted'
      format.html { redirect_to(venues_url) }
      #format.xml  { head :ok }
    end
  end
  
  private
    def check_rank
      unless can_alter? @venue
        flash[:error] = theme['rank']
        redirect_to @venue
      end
    end
    
    def fetch_venue
      @venue = Venue.find(params[:id])
    end
  
end
