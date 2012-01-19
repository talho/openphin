class TopicsController < ApplicationController
  #before_filter :authenticate
  app_toolbar "forums"

  before_filter :find_forum, :except => [:active_topics, :recent_posts]
  before_filter :find_topic, :only => [:show, :edit, :update, :destroy]
  
  # GET /topics
  # GET /topics.xml
  # GET /topics.json
  def index
    options = {:page => params[:page] || 1, :per_page => 8}
    options[:order] = "#{Topic.table_name}.sticky desc, #{Topic.table_name}.created_at desc"
    options[:conditions] = {:hidden_at => nil} unless current_user.is_super_admin?
    @topics = Topic.paginate_all_by_forum_id_and_comment_id(@forum.id,nil,options)
    for topic in @topics
      if current_user.moderator_of?(topic)
        topic[:is_moderator] = true
      end
      if current_user.is_super_admin?
        topic[:is_super_admin] = true
      end
      topic[:posts] = topic.comments.length
      topic[:user_avatar] = User.find_by_id(topic.poster_id).photo.url(:tiny)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
      format.json  {render :json => {
        :topics              => @topics.map {|x| x.as_json(:include => {:poster => {:only => [:display_name, :id]}})},
        :current_page        => @topics.current_page,
        :per_page            => @topics.per_page,
        :total_entries       => @topics.total_entries
      }}
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  # GET /topics/1.json
  def show
    options = {:page => params[:page] || 1, :per_page => params[:per_page] || 20}
    @comments = @topic.comments

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
      format.json do
        comments = []
        comments.push(@topic)
        comments.concat(@comments)
        @comments = comments.paginate(options)

        render :json => {:comments => @comments.map do |x|
                            x[:user_avatar] = x.poster.photo.url(:thumb)
                            x[:is_moderator] = current_user.moderator_of?(x)
                            x[:formatted_content] = RedCloth.new(h(x.content)).to_html
                            x.as_json(:include => {:poster => {:only => [:display_name, :id, :photo] }})
                         end,
                         :is_super_admin => current_user.is_super_admin?,
                         :page => @comments.current_page,
                         :per_page => @comments.per_page,
                         :total_entries => @comments.total_entries,
                         :locked => !@topic.locked_at.nil?
        }
      end
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  # GET /topics/new.json
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
      format.json { render :json => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    respond_to do |format|
      format.html
      format.json {render :json => {:data => { 'topic[name]' => @topic.name, 'topic[content]' => @topic.content, 'topic[sticky]' => @topic.sticky,
                                               'topic[hide]' => @topic.hidden_at ? 1 : 0, 'topic[locked]' => @topic.locked_at ? 1: 0,
                                               'topic[lock_version]' => @topic.lock_version},
                                    :success => true }}
    end
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

    respond_to do |format|
      format.html { redirect_to(forum_topics_url) }
      format.xml  { head :ok }
      format.json { render :json => {:success => true}, :status => :ok }
    end
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
    @topic = @forum.topics.find(params[:id])
  end

  def merge_if(ahash,options={})
    return ahash unless ( ahash.kind_of?(Hash) && options.kind_of?(Hash) )
    if ahash
      ahash.merge!(options)
    end
  end

end
