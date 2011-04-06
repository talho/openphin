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
    model_list = ['HanAlert', 'AlertAttempt', 'Article', 'Audience',
                  'Delivery', 'Document', 'Folder', 'Topic', 'Group', 'Invitation',
                  'Organization', 'Role', 'RoleMembership', 'RoleRequest', 'User']
    models = []
    model_list.each do |m|
      models.push({'model_name' => m, 'human_name' => m.titleize.pluralize})
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

    versions = Version.find(:all, :conditions => conditions,:order => "#{params[:sort]} #{params[:dir]}", :limit => params[:limit], :offset => params[:start])
    version_list['total_count'] = Version.find(:all, :conditions => conditions).count
    version_list['versions'] = []
    versions.each do |v|
      version_attrs = v.attributes  # turn the version object to a hash to avoid attr class conflicts
      version_attrs['whodunnit'] = get_whodunnit(v)
      version_attrs['descriptor'] = get_current_descriptor(v)
      version_attrs['created_at'] = v['created_at'].to_time.to_s(:standard)
      version_attrs['object'] = nil    # hacky way to strip out the data
      version_list['versions'].push(version_attrs)
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

    #TODO: dry this up.

    version = {}
    all_versions = Version.find_all_by_item_type_and_item_id( req_ver.item_type, req_ver.item_id )
    version['version_count'] = all_versions.count
    version['version_index'] = all_versions.index(req_ver) + 1
    version['requested_version_id'] = req_ver.id
    version['descriptor'] = get_current_descriptor(req_ver)
    version['older_id'] = req_ver.previous.id unless req_ver.previous.nil?
    version['newer_id'] = req_ver.next.id unless req_ver.next.nil?
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

  def get_current_descriptor(v) # finds the current version of the record and matches descriptor_field.  Falls back to
    begin
      desc = v.item_type.constantize.find(v.item_id).to_s
    rescue ActiveRecord::RecordNotFound # record deleted
      begin
        desc = v.next.reify.to_s
      rescue NoMethodError
        desc = get_old_descriptor(v)
      end
    end
    return truncate(desc.to_s, {:length => 70})
  end

  def get_old_descriptor(v)
    begin
      desc = v.reify.to_s.nil? ? '-unknown-' : v.reify.to_s
    rescue NoMethodError
      desc = '-unknown-'
    end
    return desc
  end

  def sanitize_and_beautify_for_your_comfort(version_attributes)
    # strip the data, but still report as changed.
    hidden_attributes = ['encrypted_password', 'salt', 'token', 'phin_oid']
    date_attributes = ['created_at', 'updated_at']
    lookup_attributes = ['alert_id', 'audience_id', 'device_id', 'user_id']
    version_attributes.each do |k,v|
      unless version_attributes[k].nil?
        version_attributes[k] = '-hidden-' if hidden_attributes.include?(k)
        version_attributes[k] = version_attributes[k].to_s(:standard) if date_attributes.include?(k)
        version_attributes[k] = k.split('_').first.capitalize.constantize.find(v).to_s + ' (' + v.to_s + ')' if lookup_attributes.include?(k)
      end
    end
    return version_attributes
  end
end                           