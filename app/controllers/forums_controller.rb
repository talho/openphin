class ForumsController < ApplicationController

  before_filter :non_public_role_required
  app_toolbar "forums"

  # GET /forums
  # GET /forums.xml
  # GET /forums.json
  def index
    page = params[:page] || (params[:start].nil? ? nil : (params[:start].to_i/(params[:per_page]||10).to_i) + 1) || 1
    @forums = Forum.paginate_for(:all,current_user, page, params[:per_page]||10)
    respond_to do |format|
      format.html
      format.json  {render :json => {
        :forums => @forums.each do |f|
          f[:is_moderator] = true unless !current_user.moderator_of?(f)
          f[:threads]      = f.topics.length
        end,
        :current_page        => @forums.current_page,
        :per_page            => @forums.per_page,
        :total_entries       => @forums.total_entries,
        :is_super_admin      => current_user.is_super_admin?
      }}
    end
  end

  # GET /forums/1
  # GET /forums/1.json
  def show
    @forum = Forum.find_for(params[:id],current_user)
    respond_to do |format|
      format.html
      format.json {render :json => @forum}
    end
  end

  # GET /forums/new
  # GET /forums/new.json
  def new
    @forum = Forum.new
    respond_to do |format|
      format.html
      format.json {render :json => @forum}
    end
  end

  # POST /forums/new
  # POST /forums/new.json
  def create
    merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})
    @forum = Forum.new(params[:forum])
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
    @forum = Forum.find_for(params[:id],current_user)
    respond_to do |format|
      format.html
      format.json {render :json => @forum.as_json(:include => {:audience => {:include => {:users => {:only => [:id, :display_name, :email, :title ]},
                                                                                          :roles => {:only => [:id, :name]},
                                                                                          :jurisdictions => {:only => [:id, :name]} },
                                                                             :only => [:id] }
                                                              }
                                                  ) }
    end
  end

  # PUT /forums/1
  # PUT /forums/1.json
  def update
    @forum = Forum.find_for(params[:id],current_user)
    merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})

    # The nested attribute audience has habtm associations that don't play nicely with optimistic locking
    if(params[:forum][:audience_attributes])
      non_ids = params[:forum][:audience_attributes].reject{|key,value| key =~ /_ids$/}
      ids = params[:forum][:audience_attributes].reject{|key,value| !(key =~ /_ids$/)}
      params[:forum][:audience_attributes] = non_ids
    end

    begin
      if @forum.update_attributes(params[:forum])
        if params[:forum][:audience_attributes]
          # Once we're sure that forums and the audience itself isn't stale, we update the audience
          @audience = Audience.find_by_id(non_ids[:id])
          @audience.update_attributes(ids)
          @audience.recipients(:force => true)
          
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
