class UsersController < ApplicationController
  before_filter :authenticate, only: [:update, :destroy, :edit]
  before_filter :not_logged_in, only: [:new, :create]
  before_filter :fetch_user, except: [:index, :new, :create, :officers]
  before_filter :edit_authorize, only: [:edit, :update]
  before_filter :check_uid_provider, only: :update
  
  respond_to :html #, :xml, :json
  
  def officers
    @officers = User.officers
    respond_with @officers
  end
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.all    
    respond_with @users
  end

  # GET /users/1
  # GET /users/1.xml
  # GET /users/1.json
  def show
    respond_with @user
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new params[:user]
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user]) 
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        UsersMailer.enlist @user
        flash[:success] = current_theme 'users', 'signed_up'
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
        flash[:success] = 
          Themes::THEMES[params[:user][:theme]]['users']['updated']
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
      flash[:success] = current_theme 'users', 'destroyed'
      sign_out
      @user.destroy
      
      respond_to do |format|
        format.html do
          redirect_to root_path
        end
        #format.xml  { head :ok }
      end
    #elsif current_user.admin
    #  @user.destroy
    #  flash[:success] = current_theme 'admin_destroy'
    #  redirect_to users_path
    else
      flash[:error] = current_theme 'users', 'destroy_not_you'
      redirect_to @user
    end
  end
  
  private
    def not_logged_in
      if current_user
        flash[:error] = current_theme 'users', 'already_signed_in'
        redirect_to root_path
      end
    end
    
    def fetch_user
      @user = User.find(params[:id])
    end
    
    def edit_authorize
      if @user != current_user
        flash[:error] = current_theme 'users', 'edit_not_you'
        redirect_to @user
      end
    end
    
    def check_uid_provider
      unless params[:user][:uid] == @user.uid and 
          params[:user][:provider] == @user.provider
        flash[:error] = current_theme 'users', 'edit_uid'
        redirect_to @user
      end
    end  
end
