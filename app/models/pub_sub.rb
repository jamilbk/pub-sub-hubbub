require 'open-uri'

class PubSub < ActiveRecord::Base
  attr_accessible :blog_url, :status
  before_update :check_subscription
  before_destroy :unsubscribe!
  
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
  
  def unsubscribe!
    unsubscribe
    true
  end
  
  def subscribe(url = self.blog_url)
    perform_request('subscribe', url)
  end
  
  def unsubscribe(url = self.blog_url)
    perform_request('unsubscribe', url)
  end
  
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

  private
  
  def perform_request(request_type, url)
    if f = feed_url(url) and hub = hub_url(f)
      self.topic        = f
      self.verify_token = random_8char_string
      self.status       = "#{request_type} pending"
      self.save
      params = {
        'hub.topic'         => self.topic,
        'hub.mode'          => request_type,
        'hub.callback'      => "http://pub-sub-hubbub.herokuapp.com/pub_subs/#{self.id}/callback",
        'hub.verify'        => 'async',
        'hub.verify_token'  => self.verify_token
      }
      begin
        RestClient.post hub, params
      rescue => e
        # anything other than 200 response raises an Error
        if e.response.code.to_i == 202 # subscription request was received
          return true
        else
          self.errors.add(:blog_url, "seems invalid. Hub wouldn't take #{request_type} request. #{e.response.inspect}")
          return false
        end
      end
    else
      self.errors.add(:blog_url, "doesn't seem to contain a valid RSS / Atom feed or its feed has no hub specified.")
      return false
    end
  end
  
  def random_8char_string
    (0...8).map{65.+(rand(25)).chr}.join
  end
end

