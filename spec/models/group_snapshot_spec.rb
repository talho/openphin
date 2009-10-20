# == Schema Information
#
# Table name: group_snapshots
#
#  id          :integer(4)      not null, primary key
#  audience_id :integer(4)
#  alert_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupSnapshot do
end
