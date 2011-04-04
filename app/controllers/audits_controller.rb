class AuditsController < ApplicationController
  before_filter :admin_required
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
    versions = {}
    versions['requested_version'] = get_version(params['id']) unless Version.find(params['id']).nil?
    versions['next_version']      = get_version(Version.find(params['id']).next.id) unless Version.find(params['id']).next.nil?
    versions['previous_version']  = get_version(Version.find(params['id']).previous.id) unless Version.find(params['id']).previous.nil?
    respond_to do |format|
      format.json{ render :json => versions }
    end
  end

  def models
    model_list = ['Han Alerts', 'Alert Attempts', 'Articles', 'Audiences',
                  'Deliveries', 'Documents', 'Folders', 'Topics', 'Groups', 'Invitations',
                  'Organizations', 'Roles', 'Role Memberships', 'Role Requests', 'Users']
    models = []
    model_list.each do |m|
      models.push({'name' => m.titleize.pluralize, 'model_name' => m})
    end
    respond_to do |format|
      format.json{ render :json => { :models => models } }
    end
  end

  private

  def get_version_list(params)
    # set some defaults
    params[:start] = 0 unless params[:start]
    params[:limit] = 15 unless params[:limit]
    params[:sort] = 'id' unless params[:sort]
    params[:dir] = 'DESC' unless params[:dir]
    version_list = {}
    conditions = {}

    if params[:models] && !params['models'].delete_if{|x| x.blank?}.blank?   # checks if the models array has just a blank string, because it's messy to remove individual baseParams from an EXT store.
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

    version_list['versions'] = Version.find(:all, :conditions => conditions,:order => "#{params[:sort]} #{params[:dir]}", :limit => params[:limit], :offset => params[:start])
    version_list['total_count'] = Version.find(:all, :conditions => conditions).count
    version_list['versions'].each do |v|
      v['whodunnit'] = get_whodunnit(v)
      v['descriptor'] = get_current_descriptor(v)
      v['object'] = nil    # hacky way to strip out the data
    end
    return version_list
  end

  def get_version(id)
    req_ver = Version.find(id)
    req_rec = reify_and_get_attrs(req_ver)
    req_rec = req_ver.item_type.constantize.new.attributes if req_rec.nil?
    next_rec = reify_and_get_attrs(req_ver.next)
    prev_rec = reify_and_get_attrs(req_ver.previous)

    begin
      curr_rec = req_ver.item_type.constantize.find(req_ver.item_id).attributes
      record_deleted = false
    rescue ActiveRecord::RecordNotFound
      record_deleted = true
    end

    attrs = {}
    all_versions = Version.find_all_by_item_type_and_item_id( req_ver.item_type, req_ver.item_id )
    attrs['version_count'] = all_versions.count
    attrs['version_index'] = all_versions.index(req_ver) + 1
    attrs['requested_version_id'] = req_ver.id
    attrs['descriptor'] = get_current_descriptor(req_ver)
    attrs['older_id'] = req_ver.previous.id unless req_ver.previous.nil?
    attrs['newer_id'] = req_ver.next.id unless req_ver.next.nil?
    attrs['deleted'] = record_deleted
    attrs['model'] = req_ver.item_type
    attrs['event'] = req_ver.event.humanize
    attrs['diff_list'] = []

    changed_attributes = []
    changed_attributes.push(get_diff_keys(req_rec, next_rec))
    changed_attributes.push(get_diff_keys(req_rec, prev_rec))
    changed_attributes.push(get_diff_keys(req_rec, curr_rec))
    changed_attributes = changed_attributes.flatten.delete_if{|x| x.nil?}
    changed_attributes = req_rec.keys if changed_attributes.empty?

    changed_attributes.flatten.uniq.each{ |a|   # yuck.
      dif = []
      dif.push(a)
      dif.push(req_rec.nil?  ? '<i>-nil-</i>' : req_rec[a].nil? ? '<i>-nil-</i>' : req_rec[a] )
      dif.push(prev_rec.nil? ? '<i>-nil-</i>' : prev_rec[a].nil? ? '<i>-nil-</i>' : prev_rec[a] )
      dif.push(next_rec.nil? ? '<i>-nil-</i>' : next_rec[a].nil? ? '<i>-nil-</i>' : next_rec[a] )
      dif.push(curr_rec.nil? ? '<i>-nil-</i>' : curr_rec[a].nil? ? '<i>-nil-</i>' : curr_rec[a] )
      attrs['diff_list'].push(dif)
    }
    return attrs
  end

  def get_diff_keys(record_one, record_two)
    begin
      return record_one.diff(record_two).keys
    rescue NoMethodError
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

  def descriptor_field  # TODO: This is hacky and doesn't allow for more complicated lookups etc.  Also should default to 'name''
    {'AlertAttempt'   => 'alert_id', # should look up alert title
    'Article'         => 'title',
    'Audience'        => 'name',
    'Delivery'        => 'device_id',  # should look up device type and owner
    'Document'        => 'file_file_name',
    'HanAlert'        => 'title',
    'Folder'          => 'name',
    'Forum'           => 'name',
    'Group'           => 'name',
    'Invitation'      => 'name',
    'RoleMembership'  => 'user_id', # should lookup the user name
    'RoleRequest'     => 'user_id',    # should lookup the user name
    'Topic'           => 'content',
    'User'            => 'display_name'}
  end

  def get_current_descriptor(v) #finds the current version of the record and matches descriptor_field.  Falls back to
    begin
      desc = v.item_type.constantize.find(v.item_id)[descriptor_field[v.item_type]]
    rescue ActiveRecord::RecordNotFound
      begin
        desc = v.next.reify.attributes[descriptor_field[v.item_type]]
      rescue NoMethodError
        desc = get_old_descriptor(v)
      end
    end
    return truncate(desc.to_s, {:length => 70})
  end

  def get_old_descriptor(v)
    begin
      desc = v.reify.attributes[descriptor_field[v.item_type]]
      if desc.nil?
        desc = '-unknown-'
      end
    rescue NoMethodError
      desc = '-unknown-'
    end
    return desc
  end

  def sanitize(version_attributes)
    # strip the data, but still report as changed.
    hidden_attributes = ['encrypted_password', 'salt', 'token', 'phin_oid']
    version_attributes.each do |k,v|
      version_attributes[k] = '-hidden-' if hidden_attributes.include?(k)
    end
    return version_attributes
  end
end                           