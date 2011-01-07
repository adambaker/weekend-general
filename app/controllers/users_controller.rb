class UsersController < ApplicationController
  before_filter :authenticate, only: [:update, :destroy, :edit]
  before_filter :not_logged_in, only: [:new, :create]
  before_filter :fetch_user, except: [:index, :new, :create]
  before_filter :edit_authorize, only: [:edit, :update]
  before_filter :check_uid_provider, only: :update
  
  respond_to :html #, :xml, :json
  # GET /users
  # GET /users.xml
  def index
    @users = User.all
    @title = "Warrior muster"
    
    respond_with @users
  end

  # GET /users/1
  # GET /users/1.xml
  # GET /users/1.json
  def show
    @title = @user.name + "'s dossier"
    respond_with @user
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @title = 'New recruit enlistment'
    @user = User.new params[:user]
  end

  # GET /users/1/edit
  def edit
    @title = "Editing #{@user.name}'s dossier."
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user]) 
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        flash[:success] = current_theme 'signed_up'
        format.html { redirect_to(@user)}
        #format.xml  { render :xml      => @user, 
        #                     :status   => :created, 
        #                     :location => @user }
      else
        format.html { render :action => "new" }
        #format.xml  { render :xml    => @user.errors, 
        #                     :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:success] = current_theme 'updated'
        format.html { redirect_to(@user) }
        #format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        #format.xml  { render :xml => @user.errors, 
        #                     :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    if current_user == @user
      sign_out
      @user.destroy
      
      respond_to do |format|
        format.html do
          flash[:success] = current_theme 'destroyed'
          redirect_to root_path
        end
        #format.xml  { head :ok }
      end
    else
      flash[:error] = current_theme 'destroy_not_you'
      redirect_to @user
    end
  end
  
  helper_method :current_theme
  
  def current_theme(message)
    Themes::current_theme['users'][message]
  end
  
  private
    def not_logged_in
      if current_user
        flash[:error] = current_theme 'already_signed_in'
        redirect_to root_path
      end
    end
    
    def fetch_user
      @user = User.find(params[:id])
    end
    
    def edit_authorize
      if @user != current_user
        flash[:error] = current_theme 'edit_not_you'
        redirect_to @user
      end
    end
    
    def check_uid_provider
      unless params[:user][:uid] == @user.uid and 
          params[:user][:provider] == @user.provider
        flash[:error] = current_theme 'edit_uid'
        redirect_to @user
      end
    end
    
end
