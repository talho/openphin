class GenerateAuthTokens < ActiveRecord::Migration
  def self.up
    User.find(:all, :conditions => {:remember_token => nil}).each do |u|
      u.send(:generate_remember_token)
      u.save
    end
  end

  def self.down
    User.all.each do |u|
      u.remember_token = nil
      u.save
    end
  end
end
