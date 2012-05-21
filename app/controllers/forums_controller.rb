class ForumsController < ApplicationController
  respond_to :json

  # GET /forums
  # GET /forums.xml
  # GET /forums.json
  def index
    @forums = Forum.for_user(current_user).where('parent_id is null')
    respond_with(@forums)      
  end

  # GET /forums/1
  # GET /forums/1.json
  def show
    @forum = Forum.for_user(current_user).find(params[:id])
    respond_with(@forums)
  end

  # GET /forums/new
  # GET /forums/new.json
  def new    
    if (current_user.is_admin?)
      @forum = Forum.new
      respond_with(@forum)
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => 'Unauthorized request for new forum', :status => 401}}
      end
    end
  end

  # POST /forums
  # POST /forums.json
  def create
    if (current_user.is_admin?)
      merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})      
      @forum = Forum.new(params[:forum])
      @forum.owner_id = current_user.id
      if @forum.save
        respond_to do |format|
          format.json {render :json => {:success => true}}
        end
      else
        respond_to do |format|
          format.json {render :json => {:success => false, :msg => @forums.errors.join(". ")}, :status => 406}
        end
      end
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => 'Unauthorized post request for create forum', :status => 401}}
      end
    end
  end

  # GET /forums/1/edit
  # GET /forums/1/edit.json
  def edit
    @forum = Forum.find(params[:id])
    if (current_user.is_admin? || current_user.moderator_of?(@forum) || current_user.forum_owner_of?(@forum))      
      respond_with(@forum)
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => 'Unauthorized get request for edit forum', :status => 401}}
      end
    end           
  end

  # PUT /forums/1
  # PUT /forums/1.json
  def update   
    if (current_user.is_admin? || current_user.moderator_of?(@forum) || current_user.forum_owner_of?(@forum))
      @forum = Forum.for_user(current_user).find(params[:id], :readonly => false)
      merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})      
  
      # The nested attribute audience has habtm associations that don't play nicely with optimistic locking
      if params[:forum][:audience_attributes]
        non_ids = params[:forum][:audience_attributes].reject{|key,value| key =~ /_ids$/}
        audience_id = non_ids[:id]
        ids = params[:forum][:audience_attributes].reject{|key,value| !(key =~ /_ids$/)}
        params[:forum][:audience_attributes] = non_ids
      end
  
      begin
        if @forum.update_attributes(params[:forum])  
          if params[:forum][:moderator_audience_attributes]
            save_moderator_audience(merge_if(params[:forum][:moderator_audience_attributes],{:owner_id=>current_user.id}))
          end        
          if params[:forum][:audience_attributes]
            # Once we're sure that forums and the audience itself isn't stale, we update the audience
            if audience_id
              @audience = Audience.find(audience_id)
              @audience.update_attributes(ids)
              
              # Force a lock_version increment for stale object detection on the audience itself
              Audience.update_counters params[:forum][:audience_attributes][:id], {} 
            else
              @forum.audience = Audience.new
              @forum.audience.update_attributes(ids)
            end            
          end
  
          if params[:forum][:topic_attributes]
            redirect_to forum_topics_path(@forum)
          else
            respond_to do |format|
              format.json {render :json => {:success => true}, :status => 200}
            end
          end
        else
          redirect_to :back
        end
      rescue ActiveRecord::StaleObjectError
        respond_to do |format|
          format.json {render :json => {:success => false, :msg => "This forum was recently changed by another user. Please try again."}, :status => 406}
        end
      rescue StandardError => e
        respond_to do |format|
          format.json {render :json => {:success => false, :msg => "There was a problem updating the forum", :error => e.to_s}, :status => 400}
        end
      end
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => 'Unauthorized put request for update forum', :status => 401}}
      end
    end
  end

  # DELETE /forums/1
  # DELETE /forums/1.json
  def destroy        
    if (current_user.is_admin? || current_user.forum_owner_of?(@forum))
      @forum = Forum.for_user(current_user).find(params[:id])
      @forum.destroy
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => 'Unauthorized delete request for destroy forum', :status => 401}}
      end
    end   
  end
  
protected

  def merge_if(ahash,options={})
    # only merge in the options if the attributes have other values indicating valid attributes
    return ahash unless ( ahash.kind_of?(Hash) && options.kind_of?(Hash) )
    if ahash
      ahash.merge!(options)
    end
  end
  
  def save_moderator_audience(attributes)
    attributes = attributes.reject{|key,value| !(key =~ /_ids$/)}
    if !@forum.moderator_audience
      @forum.moderator_audience = Audience.new      
    end
    @forum.moderator_audience.update_attributes(attributes)
    @forum.save
  end
end
