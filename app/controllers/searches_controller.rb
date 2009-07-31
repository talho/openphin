class SearchesController < ApplicationController
  before_filter :non_public_role_required
  
  def show  
    params[:q] ||= ''
    if params[:q].strip.size == 0
      search_size = 30
    else
      search_size = 300
    end
    @results = User.search(params[:q].split(/\s/).map{|x| x+'*'}.join(' '), :match_mode => :any, :per_page => search_size)
    
    respond_to do |format|
      format.html
      format.json {render :json => @results.map{|u| {:caption => u.name, :value => u.id}} }
    end
  end

end
