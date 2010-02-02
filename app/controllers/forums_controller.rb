class ForumsController < ApplicationController

  app_toolbar "forums"
  before_filter :non_public_role_required

  def index
    @forums = Forum.accessible_by(Forum.visible_to(current_user),current_user)
  end
  
  def show
    @forum = Forum.find(params[:id])
  end
  
  def new
    @forum = Forum.new
  end
  
  def create
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = "Forum was successfully created."
      redirect_to forums_url
    else
      render :action => 'new'
    end
  end
  
  def edit
    @forum = Forum.accessible_by(Forum.visible_to(current_user),current_user).detect{|f| f.id == params[:id].to_i}
  end
  
  def update
    @forum = Forum.find(params[:id])
    if @forum.update_attributes(params[:forum])
      if params[:forum][:topics_attributes]
        flash[:notice] = "Topic was successfully created."
        redirect_to( forum_topics_path(@forum) )
      else
        flash[:notice] = "Forum was successfully updated."
        redirect_to forums_path
      end
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @forum = Forum.find(params[:id])
    @forum.destroy
    flash[:notice] = "Forum was successfully removed."
    redirect_to forums_url
  end
end
