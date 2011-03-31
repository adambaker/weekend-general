class TrailsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_target
  
  def create
    current_user.track @target
    respond_to do |format|
      format.html { redirect_to @target }
      format.json {}
    end
  end

  def destroy
    current_user.untrack @target
    respond_to do |format|
      format.html { redirect_to @target }
      format.json {}
    end
  end
  
  private
    def fetch_target
      @target = User.find_by_id(params[:user_id])
    end
end
