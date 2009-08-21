class SearchesController < ApplicationController
  before_filter :non_public_role_required
  
  def show  
    if !params[:tag].blank?
      search_size = 300
      @results = User.search("*" + params[:tag].split(/\s/).map{|x| x+'*'}.join(' '), :match_mode => :any, :per_page => search_size)
    end
    
    respond_to do |format|
      format.html
      format.json {render :json => @results.map{|u| {:caption => u.name, :value => u.id}} }
    end
  end

end
