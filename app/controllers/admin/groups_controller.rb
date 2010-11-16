class Admin::GroupsController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

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
        format.json {render :json => { :groups => @groups.map { |x| {:id => x.id, :name => x.name, :scope => x.scope, :lock_version => x.lock_version, # remapping these to get a group json that plays nice with EXT 
                                                                     :owner => {:id => x.owner.id, :display_name => x.owner.display_name, :profile_path => user_profile_path(x.owner) }, :group_path => admin_group_path(x)} },
                            :count => groups.length, :page => page, :per_page => 10 } }
      end
    end
  end

  def show
    group = Group.find_by_id(params[:id])
    @group = current_user.viewable_groups.include?(group) ? group : nil
    @recipients = @group.recipients.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 30, :order => "last_name")

    respond_to do |format|
      format.html do
        if @group
        end
      end
      format.pdf do
        prawnto :inline => false, :filename => "#{@group.name.gsub(/\s/, '_')}.pdf"
      end
      format.csv do
        @csv_options = { :col_sep => ',', :row_sep => "\r\n" }
        @filename = "#{@group.name.gsub(/\s/, '_')}.csv"
        @output_encoding = 'UTF-8'
      end
      format.json do
        render :json => group_hash_for_display(@group, @recipients)
      end
    end
  end

  def new
    @group = Group.new
    @group.owner = current_user
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
    group = Group.find_by_id(params[:id])
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
          @group.update_attributes! non_ids

          # If any associations have changed, manually update the locking on groups to prevent overlapping changes
          unless @group.jurisdiction_ids.map{|j| j.to_s} == params[:group][:jurisdiction_ids].sort &&
            @group.role_ids.map{|r| r.to_s} == params[:group][:role_ids].sort &&
            @group.user_ids.map{|u| u.to_s} == params[:group][:user_ids].sort

            Group.update_counters @group.id, :lock_version => 1
          end

          @group.update_attributes! ids

          flash[:notice] = "Successfully updated the group <b>#{group.name}</b>."
          format.html { redirect_to admin_group_path(@group)}
          format.xml  { render :xml => @group, :status => :created, :location => @group }
          format.json  { render :json => {:group => group_hash_for_display(@group), :success => true}, :status => :created, :location => admin_group_path(@group) }
        rescue ActiveRecord::StaleObjectError
          group = Group.find_by_id(params[:id])
          @group = current_user.viewable_groups.include?(group) ? group : nil
          format.html {
            flash[:error] = "The group <b>#{group.name}</b> has been recently modified by another user.  Please try again."
            if @group.nil?
              flash[:error] = "This resource does not exist or is not available."
              redirect_to admin_groups_path
            else
              redirect_to edit_admin_group_path(@group)
            end
          }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
          format.json  { render :text => "The group <b>#{group.name}</b> has been recently modified by another user.  Please try again.", :status => :unprocessable_entity }
        rescue StandardError
          format.html {
            flash[:error] = "Could not save group <b>#{group.name}</b>.  Please try again."
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
      :csv_path => admin_group_path(group, :format=>:csv), :lock_version => group.lock_version,
      :users => group.users.map { |user| {:name => user.display_name, :id => user.id, :profile_path => user_profile_path(user) } },
      :jurisdictions => group.jurisdictions.map {|jurisdiction| {:name => jurisdiction.name, :id => jurisdiction.id } },
      :roles => group.roles.map {|role| {:name => role.name, :id => role.id } },
      :recipients => recipients.map { |user| {:name => user.display_name, :id => user.id, :profile_path => user_profile_path(user) } }
    }
  end
end
