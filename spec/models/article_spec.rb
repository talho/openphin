# == Schema Information
#
# Table name: articles
#
#  id         :integer(4)      not null, primary key
#  author_id  :integer(4)
#  pub_date   :integer(4)
#  title      :string(255)
#  lede       :text
#  body       :text
#  visible    :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  before(:each) do
    @valid_attributes = {
      :author_id => 1,
      :pub_date => 1,
      :title => "value for title",
      :lede => "value for lede",
      :body => "value for body",
      :visible => false
    }
  end

  it "should create a new instance given valid attributes" do
    Article.create!(@valid_attributes)
  end
end
