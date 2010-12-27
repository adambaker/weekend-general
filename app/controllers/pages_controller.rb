class PagesController < ApplicationController
  def home
    @title = "The Weekend General's home base"
  end

  def about
    @title = 'What is the Weekend General?'
  end
  
  def contact
    @title = 'Contact the administrator'
  end
end
