class TopicsController < ApplicationController
  respond_to :json
  #before_filter :authorize
  app_toolbar "forums"
  
  before_filter :find_forum, :except => [:active_topics, :recent_posts]
  before_filter :find_topic, :only => [:show, :edit, :update, :destroy]
  
  # GET /topics
  # GET /topics.xml
  # GET /topics.json
  def index
    @topics = Topic.where(:forum_id => @forum.id, :comment_id => nil).order('sticky DESC, created_at ASC')
    respond_with(@topics)
  end
  
  # GET /topics/1
  # GET /topics/1.xml
  # GET /topics/1.json
  def show
    @topics = Topic.where('comment_id = ? OR (comment_id is NULL and id = ?)', @topic.id, @topic.id).order('created_at ASC')
    respond_with(@topics)
  end

  # GET /topics/new
  # GET /topics/new.xml
  # GET /topics/new.json
  def new
    @topic = Topic.new
    respond_with(@topic)
  end

  # GET /topics/1/edit
  def edit
    #Check if moderator, creator, or admin
    respond_with(@topic)
  end

  # POST /topics
  # POST /topics.xml
  # POST /topics.json
  def create
    params[:topic][:poster_id] = current_user.id if params[:poster_id].nil?
    @topic = Topic.new(params[:topic])
    respond_to do |format|
      if @forum.topics << @topic
        format.html do
          flash[:notice] = 'Topic was successfully created.'
          redirect_to forum_topics_url
        end
        format.xml  { render :xml => @topic, :status => :created, :location => forum_topics_url }
        format.json do
          render :json => {:topic => @topic, :success => true}, :status => :created, :location => forum_topics_url
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
        format.json { render :json => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  # PUT /topics/1.json
  def update
    # no forum selected for the move, so lets set it to the original
    params[:topic][:forum_id] = params[:topic][:dest_forum_id] unless params[:topic][:dest_forum_id].blank?
    params[:topic].delete("dest_forum_id")

    unless params[:topic][:comment_attributes].nil?
      #we're going to check and make sure that the topic that we're updating isn't closed. if it's closed and there are comments, well, we need to return an error
      unless @topic.locked_at.nil?
        error = "This forum topic was closed and you will be unable to add or edit comments herein."
        respond_to do |format|
          format.html do
            flash[:error] = error
            redirect_to forum_topic_path(@topic)
          end
          format.json {render :json => {:success => false, :msg => error}, :status => 406}
        end
        return
      end
      params[:topic][:comment_attributes][:poster_id] = current_user.id if params[:topic][:comment_attributes][:id].nil?
    end

    respond_to do |format|
      begin
        if @topic.update_attributes(params[:topic])
          format.html do
            flash[:notice] = 'Topic was successfully updated.'
            redirect_to( params[:commit] == "Add Comment" ? :back : forum_topics_url )
          end
          format.xml  { render :json => {:success => true} }
          format.json { render :json => {:success => true} }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
          format.json  { render :json => @topic.errors, :status => :unprocessable_entity }
        end
      rescue ActiveRecord::StaleObjectError
        error = "Another user recently updated the same topic.  Please try again."
        format.html do
          flash[:error] = error
          redirect_to edit_forum_topic_path(@topic)
        end
        format.json {render :json => {:success => false, :msg => error, :retry => true}}
      rescue StandardError => e
        error = "There was an unexpected error while saving this topic."
        format.html do
          flash[:error] = error
          redirect_to forum_topic_path(@topic)
        end
        format.json {render :json => {:success => false, :msg => error, :extra => e.message}}
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  # DELETE /topics/1.json
  def destroy
    @topic.destroy
  end
  
  def update_comments
    # update only the comments that have been checked for update and delete only those checked for delete
    topic = Topic.find(params[:id])
    comment_ids = params[:comment_ids] || []
    delete_comment_ids = params[:delete_comment_ids] || []
    comment_ids -= delete_comment_ids
    selected = params[:topic][:comments].reject{ |k,v| !comment_ids.include?(k) }

    begin
      topic.comments.delete( Topic.find(delete_comment_ids))
      Topic.update(selected.keys,selected.values)
      flash[:notice] = "Comments were successfully updated."
      redirect_to forum_topic_url(@forum,topic)
    rescue ActiveRecord::StaleObjectError
      flash[:error] = "This topic was recently changed by another user.  Please try again."
      redirect_to edit_forum_topic_path(topic)
    rescue StandardEror
      flash[:error] = "Unexpected error while attempting to save this topic."
      redirect_to forum_topic_path(topic)
    end
  end

  def active_topics
    params[:forums].delete('')
    forums = if params[:forums].blank?
      Forum.for_user(current_user)
    else
      Forum.for_user(current_user).find(:all, :conditions => {:id => params[:forums]})
    end
    
    topics = Topic.recent_topics(params[:num_entries] || 10).find(:all, :conditions => {:forum_id => forums.map(&:id)}, :include => {:comments => [:poster], :forum => {} })
    
    respond_to do |format|
      format.json {render :json => topics.map {|topic| topic.as_json(:only => [:name, :id]).merge({
                                                :forum_name => topic.forum.name,
                                                :forum_id => topic.forum.id,
                                                :last_comment_time => topic.comments.blank? ? topic.created_at : topic.comments.last.created_at, 
                                                :last_comment_poster_name => topic.comments.blank? ? topic.poster.display_name : topic.comments.last.poster.display_name,
                                                :last_comment_poster_id => topic.comments.blank? ? topic.poster.id : topic.comments.last.poster.id })
                                               }
                   }
    end
  end
  
  def recent_posts
    params[:forums].delete('')
    forums = if params[:forums].blank?
      Forum.for_user(current_user)
    else
      Forum.for_user(current_user).find(:all, :conditions => {:id => params[:forums]})
    end
    
    topics = Topic.recent(params[:num_entries] || 10).find(:all, :conditions => {:forum_id => forums.map(&:id)}, :include => {:comments => [:poster], :forum => {}, :thread => {} })
    
    respond_to do |format|
      format.json {render :json => topics.map {|topic| topic.as_json(:only => [:content, :created_at]).merge({
                                                :id => topic.thread.nil? ? topic.id : topic.thread.id,
                                                :name => topic.thread.nil? ? topic.name : topic.thread.name,
                                                :poster_avatar => topic.poster.photo.url(:thumb),
                                                :poster_name => topic.poster.display_name,
                                                :poster_id => topic.poster.id,
                                                :forum_name => topic.forum.name,
                                                :forum_id => topic.forum.id })
                                               }
                   }
    end
  end

protected

  def find_forum
    @forum = Forum.for_user(current_user).find(params[:forum_id])
  end

  def find_topic
    @topic = @forum.comments.find(params[:id])    
  end

  def merge_if(ahash,options={})
    return ahash unless ( ahash.kind_of?(Hash) && options.kind_of?(Hash) )
    if ahash
      ahash.merge!(options)
    end
  end

end
