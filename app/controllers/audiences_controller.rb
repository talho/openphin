class AudiencesController < ApplicationController

  def index
    # this will at some point possibly return all of the audience data that we need
  end

  def jurisdictions
    render :json => [build_jurisdiction_hash(Jurisdiction.root)]
  end

  def jurisdictions_flat
    render :json => Jurisdiction.root.self_and_descendants.map {|node| {:name => node.name, :id => node.id, :leaf => node.leaf?, :left => node.left, :right => node.right, :level => node.level, :parent_id => node.parent_id} }
  end

  def roles
    render :json => current_user.is_admin? ? Role.all : Role.user_roles
  end

  def groups
    render :json => (current_user.visible_groups | Organization.non_foreign.map(&:group)).flatten.compact
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
