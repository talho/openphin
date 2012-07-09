class AudiencesController < ApplicationController
  
  def index
    # this will at some point possibly return all of the audience data that we need
  end

  def jurisdictions
    render :json => [build_jurisdiction_hash(Jurisdiction.root)]
  end

  def jurisdictions_flat
    jurisdictions = Jurisdiction.root.self_and_descendants
    jurisdictions.delete_if { |j| j.foreign } if params[:ns] == "nonforeign"
    data = Array.new
    Jurisdiction.each_with_level(jurisdictions) { |j,level|
      data << {:name => j.name, :id => j.id, :leaf => j.leaf?, :left => j.left, :right => j.right, :level => level, :parent_id => j.parent_id}
    }
    render :json => data
  end

  def groups
    render :json => (current_user.visible_groups | Organization.non_foreign.map(&:group)).flatten.compact
  end

  def determine_recipients
    audience = {:group_ids => params[:group_ids].compact.reject{|x| x.empty?}.map{ |id| id },
       :jurisdiction_ids => params[:jurisdiction_ids].compact,
       :role_ids => params[:role_ids].compact,
       :user_ids => params[:user_ids].compact
      }
    @json = nil
    Audience.transaction do
      audience = Audience.create(audience)
      @json = audience.recipients.uniq.map {|user| {'name' => user.display_name, 'id' => user.id, 'profile_path' => user_profile_path(user)}}
      raise ActiveRecord::Rollback
    end
    render :json => @json
  end

  def recipients
    audience = Audience.find(params[:audience_id])
    
    respond_to do |format|
      format.json {render :json => audience.recipients.map{ |u| {:caption => "#{u.name} #{u.email}", :name => u.name, :email => u.email, :id => u.id, :title => u.title,
                                      :tip => render_to_string(:partial => 'searches/extra.json', :locals => {:user => u})} } }
    end
  end

  private

  def build_jurisdiction_hash(jurisdiction, level = 0)
    jur_hash = {:text => jurisdiction.name, :id => jurisdiction.id, :leaf => jurisdiction.leaf?}

    unless jurisdiction.leaf? || level == 1
      jur_hash[:children] = jurisdiction.children.map{|child| build_jurisdiction_hash(child, level == 0 ? 0 : level - 1)}
    end

    jur_hash
  end
end
