require 'feedzirra'

class RssFeedController < ApplicationController
  def index
    urls = params[:urls].to_a.reject{|u| u.blank?}
    urls.each{|u| u.insert(0, "http://") } #clean up urls to ensure they're lead by http://
    feed = Feedzirra::Feed.fetch_and_parse(urls) unless urls.blank?
    
    # Need to split out the strange way it returns all of the different feeds
    feeds = feed.nil? ? [] : feed.values
    
    feeds.each{|f| f.sanitize_entries!}
    entries = feeds.map{|f| f.entries.map{|e| {:title => e.title, :date => e.published, :url => e.url, :content => e.content, :summary => e.summary, :feed_title => f.title } } }.flatten
    respond_to do |format|
      format.json { render :json => entries.sort_by{|e| e[:date]}.reverse.paginate(:page => 1, :per_page => (params[:num_entries] || 10).to_i ) }
    end
  end
end
