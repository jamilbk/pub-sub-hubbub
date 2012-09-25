require 'open-uri'

class PubSub < ActiveRecord::Base
  attr_accessible :blog_url, :status
  before_update :check_subscription
  before_destroy :unsubscribe
  
  # if URI can't understand it it's not a valid URL
  validates_format_of :blog_url, with: URI::regexp(%w(http https))
  
  # Unsubscribes from old Pubsub if blog_url changes
  def check_subscription
    unless self.blog_url_was == self.blog_url
      unless unsubscribe(self.blog_url_was) and subscribe(self.blog_url)
        self.errors.add(:blog_url, "might be invalid -- double check to ensure it 
          has an RSS/Atom feed and the feed contains <link rel='hub'...")
      end
    end
  end
  
  def subscribe(url = self.blog_url)
    if f = feed_url(url) and hub = hub_url(f)
      self.topic = feed_url(url)
      self.verify_token = (0...8).map{65.+(rand(25)).chr}.join # random 8-char string
      self.status = "subscription pending"
      self.save
      params = {
        'hub.topic'         => self.topic,
        'hub.mode'          => 'subscribe',
        'hub.callback'      => "http://thawing-thicket-1956.herokuapp.com/pub_subs/#{self.id}/callback",
        'hub.verify'        => 'async',
        'hub.verify_token'  => self.verify_token
      }
      begin
        RestClient.post hub, params
      rescue => e
        logger.info e
        if e.response.code == 202 # subscription request was received
          return true
        else
          self.errors.add(:blog_url, "seems invalid. Hub wouldn't take subscription request. #{e}")
          return false
        end
      end
    else
      self.errors.add(:blog_url, "doesn't seem to contain a valid RSS / Atom feed or its feed has no hub specified.")
      return false
    end
  end
  
  def unsubscribe(url = self.blog_url)
    if hub = hub_url(feed_url(url))
      self.status = "unsubscribed"
    else
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
  def feed_url(url=self.blog_url)
    blog = Nokogiri::HTML(open(url))
    
    # select 
    if (feed = blog.xpath("html/head/link[@rel='alternate']")).present?
      feed.attribute("href").text
    else
      nil
    end
  end

  # Fetches the PubSubHubbub Hub URL from a blog's RSS / Atom feed, if it
  # has one. A hub URL is indicated by <link rel="hub"> in the feed.
  def hub_url(url=feed_url)
    feed = Nokogiri::XML(open(url))
    
    # xpath of //*[@rel='hub'] is used instead of //link[@rel='hub'] since 
    # the link element may be under different XML namespaces, e.g.
    # <atom:link> or <rss:link> etc
    if (hub = feed.xpath("//*[@rel='hub']")).present?
      hub.attribute("href").text
    else
      nil
    end
  end
end

