class AuditsController < ApplicationController
  before_filter :admin_required
  before_filter :change_include_root
  after_filter :change_include_root_back

  # Returns version information.
  # If a specific version ID is received, returns:
  #   what changed in a specific Version,
  #   what the changed values were in the previous version,
  #   What values are different between this and the latest version.
  #
  # Otherwise, return a list of versions, respecting optional param 'model'


  def show
    if params[:id]   # requesting an individual record.
      attrs = get_version(params)
      respond_to do |format|
        # sent as arrays for EXT xtemplate ease-of-use
        format.json { render :json =>  {:requested_version => attrs['req'].to_a,
                                        :previous_version => attrs['prev'].to_a,
                                        :current_version => attrs['curr'].to_a,
                                        :version_count => attrs['version_count'],
                                        :descriptor => attrs['descriptor'] } }
      end
    else             # requesting a list of versions.
      version_list = get_list(params)
      respond_to do |format|
          format.json { render :json => {:versions => version_list['versions'], :total_count => version_list['total_count']} } 
      end
    end
  end

  private

  # for human-readablity
  def descriptor_field
    {'User' => 'display_name'}
  end

  def get_version(params)
    if params[:step] == 'next'
      version_record = Version.find(params[:id].to_i).next
    elsif params[:step] == 'previous'
      version_record = Version.find(params[:id].to_i).previous
    else
      version_record = Version.find(params[:id].to_i)
    end
    attr = {}
    # Get total versions for this record
    attr['version_count'] = Version.find_all_by_item_type_and_item_id(version_record.item_type, version_record.item_id ).count
    # Get diffs.
    if !version_record.reify.nil?
      requested_version = version_record.reify.attributes
      previous_version = version_record.previous
      if !previous_version.nil? && !previous_version.reify.nil?
        previous_version = previous_version.reify.attributes
        attr['prev'] = previous_version.diff(requested_version)
        attr['req'] = requested_version.diff(previous_version)
        attr['prev'] = sanitize(attr['prev'])
      else                  #no older version, nothing to compare to.
        attr['prev'] = ['none']
        attr['req'] = requested_version
      end
      attr['req'] = sanitize(attr['req'])
    else                    # something's weird, maybe an empty object
      requested_version = {}
      attr['prev'] = ['none']
      attr['req'] = ['none']
    end

    begin
      current_version = version_record.item_type.constantize.find(version_record.item_id).attributes
      attr['curr'] = current_version.diff(requested_version)
      attr['curr'] = sanitize(attr['curr'])
      attr['descriptor'] = get_descriptor(version_record)
    rescue ActiveRecord::RecordNotFound
      attr['curr'] = ['none']
    end
    return attr
  end

  def get_list(params)

    # set some defaults
    params[:start] = 0 unless params[:start]
    params[:limit] = 15 unless params[:limit]
    params[:sort] = 'id' unless params[:sort]
    params[:dir] = 'DESC' unless params[:dir]
    version_list = {}

    if params[:model]
      version_list['versions'] = Version.find(:item_type => params[:model], :order => "#{params[:sort]} #{params[:dir]}", :limit => params[:limit], :offset => params[:start] )
      version_list['total_count'] = Version.find(:item_type => params[:model]).count
    else
      version_list['versions'] = Version.find(:all, :order => "#{params[:sort]} #{params[:dir]}", :limit => params[:limit], :offset => params[:start] )
      version_list['total_count'] = Version.count
    end
    version_list['versions'].each do |v|
      begin
        v.whodunnit = User.find(v.whodunnit).email
      rescue ActiveRecord::RecordNotFound
        v.whodunnit = 'system'
      end
      v['descriptor'] = get_descriptor(v)
    end
    return version_list
  end

  def get_descriptor(v)
    return v.item_type.constantize.find(v.item_id)[descriptor_field[v.item_type]]
  end

  def sanitize(version_attributes)
    # don't show the data in these elements, but do report them as changed.
    hidden_attributes = ['encrypted_password', 'salt', 'token', 'phin_oid']
    version_attributes.each do |k,v|
      version_attributes.delete(k) if v.nil?
      version_attributes[k] = '-hidden-' if hidden_attributes.include?(k)
    end
    return version_attributes
  end

end                           