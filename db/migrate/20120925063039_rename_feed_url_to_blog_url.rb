class RenameFeedUrlToBlogUrl < ActiveRecord::Migration
  def up
    rename_column :pub_subs, :feed_url, :blog_url
  end

  def down
    rename_column :pub_subs, :blog_url, :feed_url
  end
end
