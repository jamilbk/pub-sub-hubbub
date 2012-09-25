require 'open-uri'

class PubSub < ActiveRecord::Base
  attr_accessible :blog_url, :status
  before_create :subscribe, :if => Proc.new { |pub_sub| pub_sub.blog_url.present? }
  # before_update :subscribe, :if => Proc.new { |pub_sub| pub_sub.blog_url.present? }
  
  # ensure valid feed URL
  validates_format_of :blog_url, with: URI::regexp(%w(http https))
  
  def subscribe
    if true
      if self.status == "subscribed"
        # unsubscribe from the first one first
        unsubscribe
      else
        self.status = "subscribed"
      end
    else
      self.errors.add(:blog_url, "might be invalid -- double check to ensure its RSS/Atom feed contains <link rel='hub'...")
      return false
    end
  end
  
  def unsubscribe
    if true
      self.status = "unsubscribed"
    else
      self.errors.add(:blog_url, "is ummm wrong? Couldn't unsubscribe from feed")
      return false
    end
  end
    
    # 1. Fetch the Blog url
    # 2. Look for blog's rss / atom feed
    # 3. set this as hub.topic
    # 4. Fetch blog feed URL
    # 5. Look for rel="hub"
    # 6. Post hub data (subscribe) to this URL, synchronously
    # 7. Listen for verification response
    # 8. Echo back challenge
    # 9. Ensure success
  
  # Fetches a blog's feed URL from a standard HTTP URL. A blog's feed is
  # usually indicated by a <link rel="alternate"> inside <head>
  def feed_url
    blog = Nokogiri::HTML(open(self.blog_url))
    
    # select 
    if url = blog.xpath("html/head/link[@rel='alternate']").attribute("href")
      url.text
    else
      nil
    end
  end

  # Fetches the PubSubHubbub Hub URL from a blog's RSS / Atom feed, if it
  # has one. A hub URL is indicated by <link rel="hub"> in the feed.
  def hub_url
    logger.debug feed_url
    feed = Nokogiri::XML(open(feed_url))
    
    # xpath of //*[@rel='hub'] is used instead of //link[@rel='hub'] since 
    # the link element may be under different XML namespaces, e.g.
    # <atom:link> or <rss:link> etc
    if hub = feed.xpath("//*[@rel='hub']").attribute("href")
      hub.text
    else
      nil
    end
  end
end

