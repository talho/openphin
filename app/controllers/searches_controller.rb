class SearchesController < ApplicationController
  before_filter :non_public_role_required
  
  def show
    @results = User.search(params[:q])
  end

end
