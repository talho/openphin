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
