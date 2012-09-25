require 'test_helper'

class PubSubTest < ActiveSupport::TestCase
  def setup
    @tumblr = pub_subs(:tumblr)
    @wordpress = pub_subs(:wordpress)
    @blogspot = pub_subs(:blogspot)
  end
  
  test "retrieves feed url from blog" do
    assert_equal("http://eidosmontreal.tumblr.com/rss", @tumblr.feed_url)
    assert_equal("http://techcrunch.wordpress.com/feed/", @wordpress.feed_url)
    assert_equal("http://blogsofnote.blogspot.com/feeds/posts/default", @blogspot.feed_url)
  end
  
  test "retrieves hub url from feed" do
    assert_equal("http://tumblr.superfeedr.com/", @tumblr.hub_url)
    assert_equal("http://techcrunch.wordpress.com/?pushpress=hub", @wordpress.hub_url)
    assert_equal("http://pubsubhubbub.appspot.com/", @blogspot.hub_url)
  end
end
