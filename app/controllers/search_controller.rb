class SearchController < ApplicationController
  def person
    name=params[:person][:name]
    @users = User.find(:all,
      :conditions => ["first_name like ? or last_name like ? or display_name like ?", "#{name}%", "#{name}%", "%#{name}%"])
    
  end

  def jurisdiction
  end

  def index
    
  end

end
