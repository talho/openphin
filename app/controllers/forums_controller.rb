class ForumsController < ApplicationController
  # GET /forums
  # GET /forums.xml
  # GET /forums.json
  respond_to :json
  
  def index
      respond_with(@forums = Forum.for_user(current_user))      
  end

  # GET /forums/1
  # GET /forums/1.json
  def show
    @forum = Forum.for_user(current_user).find(params[:id])
  end

  # GET /forums/new
  # GET /forums/new.json
  def new
    @forum = Forum.new
  end

  # POST /forums
  # POST /forums.json
  def create
    merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})
    @forum = Forum.new(params[:forum]) if current_user.is_super_admin?
    if @forum.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Forum was successfully created."
          redirect_to forums_url, {:params => params}
        end
        format.json {render :json => {:success => true}}
      end
    else
      respond_to do |format|
        format.html {render :action => 'new'}
        format.json {render :json => {:success => false, :msg => @forums.errors.join(". ")}, :status => 406}
      end
    end
  end

  # GET /forums/1/edit
  # GET /forums/1/edit.json
  def edit
    @forum = Forum.find(params[:id]) if current_user.is_super_admin?        
  end

  # PUT /forums/1
  # PUT /forums/1.json
  def update
    @forum = Forum.for_user(current_user).find(params[:id])
    merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})

    # The nested attribute audience has habtm associations that don't play nicely with optimistic locking
    if(params[:forum][:audience_attributes])
      non_ids = params[:forum][:audience_attributes].reject{|key,value| key =~ /_ids$/}
      audience_id = non_ids[:id]
      ids = params[:forum][:audience_attributes].reject{|key,value| !(key =~ /_ids$/)}
      params[:forum][:audience_attributes] = non_ids
    end

    begin
      if @forum.update_attributes(params[:forum])
        if params[:forum][:audience_attributes]
          # Once we're sure that forums and the audience itself isn't stale, we update the audience
          @audience = Audience.find(audience_id)
          @audience.update_attributes(ids)
          
          # Force a lock_version increment for stale object detection on the audience itself
          Audience.update_counters params[:forum][:audience_attributes][:id], {}
        end

        if params[:forum][:topic_attributes]
          flash[:notice] = "Topic was successfully created."
          redirect_to forum_topics_path(@forum)
        else
          respond_to do |format|
            format.html do
              flash[:notice] = "Forum was successfully updated."
              redirect_to forums_path
            end
            format.json {render :json => {:success => true}, :status => 200}
          end
        end
      else
        redirect_to :back
      end
    rescue ActiveRecord::StaleObjectError
      respond_to do |format|
        format.html do
          flash[:error] = "This forum was recently changed by another user.  Please try again."
          redirect_to edit_forum_path(@forum)
        end
        format.json {render :json => {:success => false, :msg => "This forum was recently changed by another user. Please try again."}, :status => 406}
      end
    rescue StandardError => e
      respond_to do |format|
        format.html do
          flash[:error] = "There was a problem updating the forum."
          redirect_to forums_path
        end
        format.json {render :json => {:success => false, :msg => "There was a problem updating the forum", :error => e.to_s}, :status => 400}
      end
    end
  end

  # DELETE /forums/1
  # DELETE /forums/1.json
  def destroy
    @forum = Forum.for_user(current_user).find(params[:id])
    @forum.destroy    
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
