class TopicsController < ApplicationController

  before_filter :non_public_role_required
  app_toolbar "forums"

  before_filter :find_forum
  before_filter :find_topic, :only => [:show, :edit, :update, :destroy]
  
  # GET /topics
  # GET /topics.xml
  def index
    options = {:page => params[:page] || 1, :per_page => 8}
    options[:order] = "#{Topic.table_name}.sticky desc, #{Topic.table_name}.created_at desc"
    options[:conditions] = {:hidden_at => nil} unless current_user.is_super_admin?
    @topics = Topic.paginate_all_by_forum_id_and_comment_id(@forum.id,nil,options)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @comments = @topic.comments

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
   end

  # POST /topics
  # POST /topics.xml
  def create
    @topic = Topic.new(params[:topic])
    respond_to do |format|
      if @forum.topics << @topic
        flash[:notice] = 'Topic was successfully created.'
        format.html { redirect_to forum_topics_url }
        format.xml  { render :xml => @topic, :status => :created, :location => @topic }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    # no forum selected for the move, so lets set it to the original
    params[:topic][:dest_forum_id] = params[:forum_id] if params[:topic][:dest_forum_id].blank?
    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to( params[:commit] == "Add Comment" ? :back : forum_topics_url ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(forum_topics_url) }
      format.xml  { head :ok }
    end
  end
  
  def update_comments
    # update only the comments that have been checked for update and delete only those checked for delete
    topic = Topic.find(params[:id])
    comment_ids = params[:comment_ids] || []
    delete_comment_ids = params[:delete_comment_ids] || []
    comment_ids -= delete_comment_ids
    selected = params[:topic][:comments].reject{ |k,v| !comment_ids.include?(k) }
    topic.comments.delete( Topic.find(delete_comment_ids))
    Topic.update(selected.keys,selected.values)
    flash[:notice] = "Comments were successfully updated."  
    redirect_to forum_topic_url(@forum,topic)
  end

protected

  def find_forum
    @forum = Forum.find_for(params[:forum_id],current_user)
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
