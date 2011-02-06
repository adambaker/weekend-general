class EventsController < ApplicationController
  before_filter :authenticate, except: [:index, :show]
  before_filter :fetch_event, except: [:index, :new, :create]
  before_filter :check_rank, only: [:edit, :update, :destroy]
  before_filter :fetch_events, only: [:index]
  
  respond_to :html#, :xml, :json
  
  # GET /events
  # GET /events.xml
  def index
    if past?
      @events = @events.order 'date DESC'
    else
      @events = @events.order :date
    end
    respond_with @events
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    respond_with @events
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
    4.times {@event.links.build}
    respond_with @event
  end

  # GET /events/1/edit
  def edit
    @event.links.build
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.created_by = current_user.id

    respond_to do |format|
      if @event.save
        flash[:success] = current_theme 'events', 'new'
        EventsMailer.all_new_event(@event)
        format.html { redirect_to @event }
        #format.xml {render xml: @event, status: :created, location: @event}
      else
        format.html { render action: "new" }
        #format.xml {render xml: @event.errors, status: :unprocessable_entity}
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:success] = current_theme 'events', 'updated'
        format.html {redirect_to @event}
        #format.xml  { head :ok }
      else
        format.html {render action: "edit"}
        #format.xml {render xml: @event.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event.destroy

    respond_to do |format|
      flash[:success] = current_theme 'events', 'deleted'
      format.html { redirect_to(events_url) }
      #format.xml  { head :ok }
    end
  end
  
  private
  
    def fetch_event
      @event = Event.find(params[:id])
    end
    
    def check_rank
      unless can_alter? @event
        flash[:error] = theme['rank']
        redirect_to @event
      end
    end
    
    def future?
      params[:commit] =~ /future/i
    end
    def today?
      params[:commit] =~ /today/i
    end
    def week?
      params[:commit] =~ /week/i
    end
    def month?
      params[:commit] =~ /month/i
    end
    def past?
      params[:commit] =~ /past/i
    end
end
