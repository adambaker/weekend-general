class VenuesController < ApplicationController
  respond_to :html #, :xml, :json
  
  before_filter :authenticate, except: [:index, :show]
  
  # GET /venues
  # GET /venues.xml
  def index
    @venues = Venue.all
    @title = "Venues"
    
    respond_with @venues
  end

  # GET /venues/1
  # GET /venues/1.xml
  def show
    @venue = Venue.find(params[:id])
    @title = @venue.name
    
    respond_with @venue
  end

  # GET /venues/new
  # GET /venues/new.xml
  def new
    @venue = Venue.new(city: Settings::city)
    @title = 'New venue intel' 

    respond_with @venue
  end

  # GET /venues/1/edit
  def edit
    @title = 'Revise venue intel'
    @venue = Venue.find(params[:id])
  end

  # POST /venues
  # POST /venues.xml
  def create
    @venue = Venue.new(params[:venue])

    respond_to do |format|
      if @venue.save
        flash[:success] = current_theme 'new'
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
    @venue = Venue.find(params[:id])

    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        flash[:success] = current_theme 'updated'
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
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      flash[:success] = current_theme 'deleted'
      format.html { redirect_to(venues_url) }
      #format.xml  { head :ok }
    end
  end
  
  helper_method :current_theme
  
  def current_theme(message)
    Themes::current_theme['venues'][message]
  end
end
