class UsersController < ApplicationController

  # GET /users
  # GET /users.xml
  def index
    @users = User.all
    @title = "Warrior muster"
    respond_to do |format|
      format.html # index.html.erb
      #format.xml  { render :xml => @users }  add xml and json responses
      #format.json { render :json => @users } for external APIs later
    end
  end

  # GET /users/1
  # GET /users/1.xml
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @title = @user.name + "'s dossier"
    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @user }
      #format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    if current_user
      flash[:error] = "You're already signed in. You can't re-enlist."
      redirect_to root_path
    else
      @title = 'New recruit enlistment'
      @user = User.new params[:user]
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    if current_user.nil?
      redirect_to '/auth/google'
    elsif @user == current_user
      @title = "Editing #{@user.name}'s dossier."
    else
      flash[:error] = "You can't edit someone else's profile."
      redirect_to @user
    end
  end

  # POST /users
  # POST /users.xml
  def create
    if current_user.nil?
      @user = User.new(params[:user]) 
      respond_to do |format|
        if @user.save
          session[:user_id] = @user.id
          flash[:success] = "You've successfully enlisted. Now go kick some ass."
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
    else
      flash[:error] = "You're already signed in. You can't re-enlist."
      redirect_to root_path
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    
    if current_user == @user
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:success] = 'Yeah yeah. I got your personnel info filed. ' + 
            'Now quit dallying with the paperwork and get to your ops.'
          format.html { redirect_to(@user) }
          #format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          #format.xml  { render :xml => @user.errors, 
          #                     :status => :unprocessable_entity }
        end
      end
    elsif current_user.nil?
      redirect_to '/auth/google'
    else
      flash[:error] = "You can't edit someone else's profile."
      redirect_to @user
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    if current_user.nil?
      redirect_to '/auth/google'
    elsif current_user == @user
      sign_out
      @user.destroy
      
      respond_to do |format|
        format.html do
          flash[:success] = "You have your discharge. You know where the " + 
            "recruiter is if you want back in."
          redirect_to root_path
        end
        #format.xml  { head :ok }
      end
    else
      flash[:error] = "You don't have clearance to give someone " + 
        "else a discharge."
      redirect_to @user
    end
  end
  
end
