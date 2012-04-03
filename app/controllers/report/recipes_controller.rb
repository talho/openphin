class Report::RecipesController < ApplicationController

	before_filter :non_public_role_required
  caches_action :index

	# GET /report/recipes
	# GET /report/recipes.json
	def index
    recipe_names = current_user.is_admin? ? RecipeExternal.recipe_names : []
    respond_to do |format|
     format.html
     format.json do
       ActiveRecord::Base.include_root_in_json = false
       render :json => { "recipes"=> recipe_names.collect{|r| { :id => r, :name_humanized => humanized(r) } }  }
     end
    end
  end

  def show
    begin
      json = {}
      json["recipe"] = RecipeExternal.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      json["error_msg"] = "This recipe is malformed. Please inform administrator."
    end
    respond_to do |format|
      format.html
      format.json do
        ActiveRecord::Base.include_root_in_json = false
        render :json => json
      end
    end

  end

private

  def humanized(param)
    RecipeExternal.humanized(param)
  end

end