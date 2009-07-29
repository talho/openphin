class SearchesController < ApplicationController

  def show
    @results = User.search(params[:q])
  end

end
