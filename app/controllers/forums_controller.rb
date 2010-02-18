class ForumsController < ApplicationController

  before_filter :non_public_role_required
  app_toolbar "forums"

  def index
    @forums = Forum.paginate_for(:all,current_user,params[:page] || 1)
  end
  
  def show
    @forum = Forum.find_for(params[:id],current_user)
  end
  
  def new
    @forum = Forum.new
  end
  
  def create
    merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = "Forum was successfully created."
      redirect_to forums_url
    else
      render :action => 'new'
    end
  end
  
  def edit
    @forum = Forum.find_for(params[:id],current_user)
  end
  
  def update
    @forum = Forum.find_for(params[:id],current_user)
    if @forum.update_attributes(params[:forum])
      if params[:forum][:topic_attributes]
        flash[:notice] = "Topic was successfully created."
        redirect_to( forum_topics_path(@forum) )
      else
        flash[:notice] = "Forum was successfully updated."
        redirect_to forums_path
      end
    else
      redirect_to :back
    end
  end
  
  def destroy
    @forum = Forum.find_for(params[:id],current_user)
    @forum.destroy
    flash[:notice] = "Forum was successfully removed."
    redirect_to forums_url
  end
  
protected

  def merge_if(ahash,options={})
    # only merge in the options if the attributes have other values indicating valid attributes
    return ahash unless ( ahash.kind_of?(Hash) && options.kind_of?(Hash) )
    if ahash
      ahash.merge!(options)
    end
  end
  
end
