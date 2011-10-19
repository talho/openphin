class Report::RecipesController < ApplicationController

	before_filter :non_public_role_required
  caches_action :index

	# GET /report/recipes
	# GET /report/recipes.json
	def index
    @recipes = Report::Recipe.all
    respond_to do |format|
     format.html
     format.json do
       ActiveRecord::Base.include_root_in_json = false
       render :json => { "recipes"=> @recipes.collect{|r| { :id => r, :name_humanized => humanized(r) } }  }
#     all.each { |sub| json << {:name=>sub.name,:name_humanized=>humanized(sub.name)} }
     end
    end
  end

  def show
    @recipe = Report::Recipe.find(params[:id])
    respond_to do |format|
      format.html
      format.json do
        ActiveRecord::Base.include_root_in_json = false
        render :json => {"recipe"=>@recipe}
      end
    end

  end

private

  def humanized(param)
    Report::Recipe.humanized(param)
  end

end