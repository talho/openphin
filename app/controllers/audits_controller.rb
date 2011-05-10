class AuditsController < ApplicationController
  before_filter :super_admin_in_texas_required
  before_filter :change_include_root
  after_filter :change_include_root_back

  def index
    version_list = get_version_list(params)
    respond_to do |format|
      format.json{ render :json => {
        :versions => version_list['versions'],
        :total_count => version_list['total_count'] }
      }
    end
  end

  def show
    if allowed_to_see(params['id'])
      versions = {}
      versions['requested_version'] = get_version(params['id']) unless Version.find(params['id']).nil?
      versions['next_version']      = get_version(Version.find(params['id']).next.id) unless Version.find(params['id']).next.nil?
      versions['previous_version']  = get_version(Version.find(params['id']).previous.id) unless Version.find(params['id']).previous.nil?
      versions.delete_if{|k,v| v.nil?}
      respond_to do |format|
        format.json{ render :json =>{ :success=>true, :versions=>versions } }
      end
    else
      respond_to do |format|
        format.json { render :json =>{:success=>false, :response=>"You do not have permission to view this record."} }
        format.all { render :text => 'You do not have permission to view this record.'}
      end
    end
  end

  def models
    model_list = ['AlertAttempt', 'AlertDeviceType', 'AlertAckLog', 'Article', 'Audience', 'DelayedJobCheck', 'Delivery', 'Device',
                  'Document', 'Favorite', 'Folder', 'FolderPermission', 'Forum', 'Group', 'HanAlert', 'Invitation','Invitee', 'Jurisdiction',
                  'Organization', 'OrganizationMembershipRequest', 'Role', 'RoleMembership', 'RoleRequest', 'Target', 'Topic', 'User']
    models = []
    model_list.each do |m|
      models.push({'model_name' => m, 'human_name' => m.titleize.pluralize})
    end
    respond_to do |format|
      format.json{ render :json => { :models => models } }
    end
  end

  private

  def allowed_to_see(id)
    return true if current_user.is_sysadmin?
    return current_user.visible_actors.include?(User.find(Version.find(id).whodunnit)) unless Version.find(id).whodunnit.nil?
    false
  end

  def get_version_list(params)
    # set some defaults
    params[:start] = 0 unless params[:start]
    params[:limit] =  30 unless params[:limit]
    params[:sort] = 'id' unless params[:sort]
    params[:dir] = 'DESC' unless params[:dir]
    version_list = {}
    conditions = {}

    if params[:models] && !params['models'].delete_if{|x| x.blank?}.blank? # checks if the models array has just a blank string, because it's messy to remove individual baseParams from an EXT store.
      conditions['item_type'] = params[:models]
    end
    if params[:show_versions_for]
      selected_ver = Version.find(params[:show_versions_for])
      conditions['item_type'] = selected_ver['item_type']
      conditions['item_id'] = selected_ver['item_id']
    end
    if params[:event] && !params['event'].delete_if{|x| x.blank?}.blank?   # what ^ he said
      conditions['event'] = params[:event]
    end

    #don't show user actions by users with apps that current_user doesn't have
    conditions['whodunnit'] = current_user.visible_actors.map(&:id).map(&:to_s) unless current_user.is_sysadmin?

    versions = Version.find(:all, :conditions => conditions, :order => "#{params[:sort]} #{params[:dir]}", :limit => params[:limit], :offset => params[:start])
    version_list['total_count'] = Version.find(:all, :conditions => conditions).count
    version_list['versions'] = []
    versions.each do |v|
      version_attrs = v.attributes  # turn the version object to a hash to avoid attr class conflicts
      version_attrs['whodunnit'] = get_whodunnit(v)
      version_attrs['item_desc'] = v['item_desc']
      version_attrs['created_at'] = v['created_at'].to_time.to_s(:standard)
      version_attrs['object'] = nil    # hacky way to strip out the data
      version_list['versions'].push(version_attrs)
    end
    return version_list
  end

  def get_version(id)
    if allowed_to_see(id)
      req_ver = Version.find(id)
      req_rec = reify_and_get_attrs(req_ver)
      req_rec = req_ver.item_type.constantize.new.attributes if req_rec.nil?
      next_rec = reify_and_get_attrs(req_ver.next)
      prev_rec = reify_and_get_attrs(req_ver.previous)

      begin
        current_record = req_ver.item_type.constantize.find(req_ver.item_id)
        curr_rec = allowed_to_see(current_record.versions.last.id.to_i) ? current_record.attributes : nil
        record_deleted = false
      rescue ActiveRecord::RecordNotFound
        record_deleted = true
      end

      #TODO: dry this up!
      version = {}
      all_versions = Version.find(:all, :conditions => {:item_type => req_ver.item_type, :item_id => req_ver.item_id }, :order => 'id ASC' )
      version['version_count'] = all_versions.count
      version['version_index'] = all_versions.index(req_ver) + 1
      version['requested_version_id'] = req_ver.id
      version['descriptor'] = req_ver.item_desc
      version['older_id'] = req_ver.previous.id unless req_ver.previous.nil? || !allowed_to_see(req_ver.previous.id)
      version['newer_id'] = req_ver.next.id unless req_ver.next.nil? || !allowed_to_see(req_ver.next.id)
      version['deleted'] = record_deleted
      version['model'] = req_ver.item_type
      version['event'] = req_ver.event.humanize
      version['diff_list'] = []

      changed_attributes = []
      changed_attributes.push(get_diff_keys(req_rec, next_rec))
      changed_attributes.push(get_diff_keys(req_rec, prev_rec))
      changed_attributes.push(get_diff_keys(req_rec, curr_rec))
      changed_attributes = changed_attributes.flatten.delete_if{|x| x.nil?}
      changed_attributes = req_rec.keys if changed_attributes.empty?

      req_rec = sanitize_and_beautify_for_your_comfort(req_rec) unless req_rec.nil?
      prev_rec = sanitize_and_beautify_for_your_comfort(prev_rec) unless prev_rec.nil?
      next_rec = sanitize_and_beautify_for_your_comfort(next_rec) unless next_rec.nil?
      curr_rec = sanitize_and_beautify_for_your_comfort(curr_rec) unless curr_rec.nil?

      changed_attributes.flatten.uniq.each{ |a|   # yuck.
        dif = []
        dif.push(a)
        dif.push(req_rec.nil?  ? '<i>-nil-</i>' : req_rec[a].nil?  ? '<i>-nil-</i>' : req_rec[a] )
        dif.push(prev_rec.nil? ? '<i>-nil-</i>' : prev_rec[a].nil? ? '<i>-nil-</i>' : prev_rec[a] )
        dif.push(next_rec.nil? ? '<i>-nil-</i>' : next_rec[a].nil? ? '<i>-nil-</i>' : next_rec[a] )
        dif.push(curr_rec.nil? ? '<i>-nil-</i>' : curr_rec[a].nil? ? '<i>-nil-</i>' : curr_rec[a] )
        version['diff_list'].push(dif)
      }
      return version
    else
      return nil
    end
  end

  def get_diff_keys(record_one, record_two)
    begin
      return record_one.diff(record_two).keys
    rescue
    end    
  end

  def reify_and_get_attrs(v)
    begin
      return v.reify.attributes
    rescue NoMethodError
    end
  end

  def get_whodunnit(v)
    begin
        return  User.find(v.whodunnit).email
      rescue ActiveRecord::RecordNotFound
        return 'system/unknown'
      end
  end

  def sanitize_and_beautify_for_your_comfort(version_attributes)
    # strip the data, but still report as changed.
    hidden_attributes = ['encrypted_password', 'salt', 'token', 'phin_oid']
    date_attributes = ['created_at', 'updated_at', 'file_updated_at']
    lookup_attributes = {'alert_id' => Alert, 'alert_attempt_id' => AlertAttempt, 'approver_id' => User, 'audience_id' => Audience, 'author_id' => User,
                         'device_id' => Device, 'folder_id' => Folder, 'forum_id' => Forum, 'from_jurisdiction_id' => Jurisdiction, 'group_id' => Group,
                         'invitation_id' => Invitation, 'jurisdiction_id' => Jurisdiction, 'organization_id' => Organization, 'owner_id' => User,
                         'parent_id' => Jurisdiction, 'poster_id' => User, 'requester_id' => User, 'role_id' => Role, 'user_id' => User}
    version_attributes.each do |k,v|
      unless version_attributes[k].nil?
        version_attributes[k] = '-hidden-' if hidden_attributes.include?(k)
        version_attributes[k] = version_attributes[k].to_s(:standard) if date_attributes.include?(k)
        version_attributes[k] = !lookup_attributes[k].find_by_id(v).nil? ? v.to_s + ' (' + lookup_attributes[k].find(v).to_s + ')' : '-deleted-' if lookup_attributes.include?(k) 
      end
    end
    return version_attributes
  end
end                           