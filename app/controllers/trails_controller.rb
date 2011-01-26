class TrailsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_target
  
  def create
    current_user.track @target
    redirect_to @target
  end

  def destroy
    current_user.untrack @target
    redirect_to @target
  end
  
  private
    def fetch_target
      @target = User.find_by_id(params[:user_id])
    end
end
