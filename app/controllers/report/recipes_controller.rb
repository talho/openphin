class Report::RecipesController < ApplicationController

	before_filter :non_public_role_required

	# GET /report/recipes
	# GET /report/recipes.json
	def index
	  Report::Recipe.register_recipes
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

	# GET /report/recipe/1
	# GET /report/recipe/1.json
	def show
	  @report = Report::Recipe.find_by_id_and_author_id(params[:id],current_user.id)
	  @data = []
	  for i in (0..20000)
	    @data << YAML::load(File.read(@report.resultset.path))
	  end
	  respond_to do |format|
	    format.html
	    format.json {render :json => @data}
	  end
	end

 end