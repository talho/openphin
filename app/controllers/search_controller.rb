class SearchController < ApplicationController
  def person
    name=params[:person][:name]
    @phin_people = PhinPerson.find(:all,
      :conditions => ["first_name like ? or last_name like ? or display_name like ?", "#{name}%", "#{name}%", "%#{name}%"])
    
  end

  def jurisdiction
  end

  def index
    
  end

end
