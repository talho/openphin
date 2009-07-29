class SearchesController < ApplicationController
  before_filter :non_public_role_required
  
  def show  
    params[:q] ||= ''
    @results = User.search(params[:q].split(/\s/).map{|x| x+'*'}.join(' '), :match_mode => :any)
    
    respond_to do |format|
      format.html
      format.json {render :json => @results.map{|u| {:caption => u.name, :value => u.id}} }
    end
  end

end
