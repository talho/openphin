# == Schema Information
#
# Table name: documents
#
#  id                :integer(4)      not null, primary key
#  owner_id          :integer(4)
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer(4)
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  user_id           :integer(4)
#  folder_id         :integer(4)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Document do
  context "viewable_by(user)" do
    before do
      @document = Factory(:document)
    end
    it "should include documents that are owned by user" do
      Document.viewable_by(@document.user).should include(@document)
    end
    
    it "should not include documents that are owned by another user" do
      Document.viewable_by(Factory(:user)).should_not include(@document)
    end
    
    it "should include documents in a channel" do
      channel = Factory(:channel)
      channel.documents << @document
      user = Factory(:user)
      channel.users << user
      Document.viewable_by(user).should include(@document)
    end
  end
  
  context "editable_by(user)" do
    before do
      @document = Factory(:document)
    end
    it "should include documents that are owned by user" do
      Document.editable_by(@document.user).should include(@document)
    end
    
    it "should not include documents that are owned by another user" do
      Document.editable_by(Factory(:user)).should_not include(@document)
    end
    
    it "should include documents in a channel owned by the user" do
      channel = Factory(:channel)
      channel.documents << @document
      user = Factory(:user)
      user.subscriptions.create!(:owner => true, :channel => channel)
      Document.editable_by(user).should include(@document)
    end
    
    it "should not include documents in a channel not owned by the user" do
      channel = Factory(:channel)
      channel.documents << @document
      user = Factory(:user)
      user.subscriptions.create!(:owner => false, :channel => channel)
      Document.editable_by(user).should_not include(@document)
    end
  end
end
