class Admin::GroupsController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"
  include Report::CreateDataSet

  def index
    page = params[:page].blank? ? "1" : params[:page]
    @reverse = params[:reverse] == "1" ? nil : "&reverse=1"
    @sort = params[:sort]
    case @sort
      when "owner"
        groups = current_user.viewable_groups.sort_by{|group| group.owner.display_name}
      when "scope"
        groups = current_user.viewable_groups.sort_by{|group| group.scope}
      else
        groups = current_user.viewable_groups.sort_by{|group| group.name}
    end
    groups.reverse! if params[:reverse] == "1"
    @groups = groups.paginate(:page => page, :per_page => 10)
    @page = (page == "1" ? "?" : "?page=#{params[:page]}")

    if request.xhr?
      respond_to do |format|
        format.html
        format.json {
          @groups = @groups.map { |x| {:id => x.id, :name => x.name, :scope => x.scope, :lock_version => x.lock_version, # remapping these to get a group json that plays nice with EXT
                                                                     :owner => owner.nil? ? {} : {:id => x.owner.id, :display_name => x.owner.display_name, :profile_path => user_profile_path(x.owner) }, :group_path => admin_group_path(x)}} unless @groups.empty?
          render :json => { :groups =>  @groups, :count => groups.length, :page => page.to_i, :per_page => 10, :start => params[:start].to_i }
        }
      end
    end
  end

  def show
    group = Group.find_by_id(params[:id])
    @group = current_user.viewable_groups.include?(group) ? group : nil

    respond_to do |format|
      if @group
        format.html
        format.any(:csv,:pdf) do
          criteria = {:model=>"Group",:method=>:find_by_id,:params=>@group[:id]}
          report = create_data_set("Report::GroupWithRecipientsRecipeInternal",criteria)
          render :json => {:success => true, :report_name=> report.name}
        end
        format.json do
          @recipients = @group ? (
            params[:no_page] == 'true' ?
            @group.recipients :
            @group.recipients.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 30, :order => "last_name")
          ) : []
          render :json => group_hash_for_display(@group, @recipients)
        end
      else
        format.html
        format.json do
          render :json => {}, :status => :unprocessable_entity
        end
      end
    end
  end

  def new
    @group = Group.new
    @group.owner = current_user
    scopes = ['Personal']
    scopes = scopes | ['Jurisdiction', 'Global', 'Organization'] if current_user.is_admin?('phin')
    respond_to do |format|
      format.html
      format.json {render :json => {:scopes => scopes}}
    end
  end

  def create
    @group = current_user.groups.build(params[:group])
    @group.owner = current_user

    respond_to do |format|
      if @group.save
        format.html { redirect_to admin_group_path(@group)}
        format.xml  { render :xml => @group, :status => :created, :location => @group }
        format.json  { render :json => {:group => group_hash_for_display(@group), :success => true}, :status => :created, :location => admin_group_path(@group) }
        flash[:notice] = "Successfully created the group #{params[:group][:name]}."
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
        format.json  { render :json => @group.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update
    group = Group.find(params[:id])
    @group = group if current_user.viewable_groups.include?(group)
    if @group.nil?
      flash[:error] = "This resource does not exist or is not available."
      redirect_to admin_groups_path
    else
      params[:group]["jurisdiction_ids"] = [] if params[:group]["jurisdiction_ids"].blank?
      params[:group]["role_ids"] = [] if params[:group]["role_ids"].blank?
      params[:group]["user_ids"] = [] if params[:group]["user_ids"].blank?

      respond_to do |format|
        begin
          # Because non-nested attributes for associations on habtm don't play well with optimistic locking
          # We must first update_attributes without associations to test for stale object, otherwise the object
          # will throw ActiveRecord::StaleObjectError, but the associations won't revert to their original state
          non_ids = params[:group].reject{|key,value| key =~ /_ids$/}
          ids = params[:group].reject{|key,value| !(key =~ /_ids$/)}

          if params[:group][:lock_version].to_i < @group.lock_version
            raise ActiveRecord::StaleObjectError
          end
          
          # If any associations have changed, manually update the locking on groups to prevent overlapping changes
          unless @group.jurisdiction_ids.map{|j| j.to_s}.sort == params[:group][:jurisdiction_ids].sort &&
            @group.role_ids.map{|r| r.to_s}.sort == params[:group][:role_ids].sort &&
            @group.user_ids.map{|u| u.to_s}.sort == params[:group][:user_ids].sort

            @group.update_attributes! ids
          end
          
          @group.update_attributes! non_ids
          Group.update_counters @group.id, {}

          @group.reload
          @group.recipients(:force => true)
          
          format.html do
            flash[:notice] = "Successfully updated the group <b>#{group.name}</b>."
            redirect_to admin_group_path(@group)
          end
          format.xml  { render :xml => @group, :status => :created, :location => @group }
          format.json  { render :json => {:group => group_hash_for_display(@group), :success => true}, :status => :created, :location => admin_group_path(@group) }
        rescue ActiveRecord::StaleObjectError
          format.html {
            flash[:error] = "The group <b>#{@group.name}</b> has been recently modified by another user.  Please try again."
            unless current_user.viewable_groups.include?(@group)
              flash[:error] = "This resource does not exist or is not available."
              redirect_to admin_groups_path
            else
              redirect_to edit_admin_group_path(@group)
            end
          }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
          format.json  { render :text => "The group <b>#{@group.name}</b> has been recently modified by another user.  Please try again.", :status => :unprocessable_entity }
        rescue StandardError => ex
          format.html {
            flash[:error] = "Could not save group <b>#{@group.name}</b>.  Please try again."
            redirect_to edit_admin_group_path(@group)
          }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
          format.json  { render :json => @group.errors, :status => :unprocessable_entity }
        end
      end
    end 
  end

  def edit
    group = Group.find_by_id(params[:id])
    @group = group if current_user.viewable_groups.include?(group)
    if @group.nil?
          flash[:error] = "This resource does not exist or is not available."
          redirect_to admin_groups_path
    end 
    scopes = ['Personal']
    scopes = scopes | ['Jurisdiction', 'Global', 'Organization'] if current_user.is_admin?('phin')
    respond_to do |format|
      format.html
      format.json {render :json => {:scopes => scopes, :group => group_hash_for_display(@group, @recipients)} }
    end
  end
  
  def dismember
    group = Group.find(params[:group_id])
    the_group = group if current_user.viewable_groups.include?(group)
    member = User.find(params[:member_id])
    the_group.users.delete(member) if the_group && member
    redirect_to(edit_admin_group_path(the_group))
  end


  def destroy
    group = Group.find(params[:id])
    @group = group if current_user.viewable_groups.include?(group)
    name = @group.name
    respond_to do |format|
      if @group && @group.destroy
        flash[:notice] = "Successfully deleted the group #{name}."
        format.html { redirect_to admin_groups_path }
        format.xml  { head :ok }
        format.json { render :json => {'success' => true}}
      else
        flash[:error] = "This resource does not exist or is not available."
        format.html { redirect_to admin_groups_path }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
        format.json { render :json => {'errors' => @group.errors}, :status => :unprocessable_entity}
      end
    end
  end

  private

  def group_hash_for_display(group, recipients = nil)
    if(recipients.nil?)
      recipients = group.recipients
    end

    { :name => group.name, :id => group.id, :scope => group.scope, :owner_jurisdiction => group.owner_jurisdiction_id.nil? ? nil : Jurisdiction.find(group.owner_jurisdiction_id),
      :csv_path => admin_group_path(group, :format=>:csv), :lock_version => group.lock_version, :total_recipients => recipients.methods.include?('total_entries') ? recipients.total_entries : recipients.count,
      :users => group.users.map { |user| {:name => user.display_name, :id => user.id, :profile_path => user_profile_path(user) } },
      :jurisdictions => group.jurisdictions.map {|jurisdiction| {:name => jurisdiction.name, :id => jurisdiction.id } },
      :roles => group.roles.map {|role| {:name => role.name, :id => role.id } },
      :html_path => admin_group_path(group, :format=>:html),
      :pdf_path => admin_group_path(group, :format=>:pdf),
      :recipients => recipients.map { |user| {:name => user.display_name, :id => user.id, :profile_path => user_profile_path(user) } }
    }
  end
end
