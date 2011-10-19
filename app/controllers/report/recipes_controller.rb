class Report::RecipesController < ApplicationController

	before_filter :non_public_role_required
  before_filter :register_recipes
  caches_action :index

	# GET /report/recipes
	# GET /report/recipes.json
	def index
    @recipes = Report::Recipe.deployable.find(:all, :order=>'updated_at DESC')
    respond_to do |format|
     format.html
     format.json do
       ActiveRecord::Base.include_root_in_json = false
       @recipes.collect! do |r|
         r.as_json(:inject=>{'type'=>r.class.name,'type_humanized'=>r.type_humanized, 'description'=>r.description})
       end
       render :json => {"recipes"=>@recipes}
     end
    end
	end

private

  def register_recipes
    Report::Recipe.register
  end

 end