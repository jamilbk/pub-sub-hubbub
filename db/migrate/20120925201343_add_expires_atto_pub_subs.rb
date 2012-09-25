class AddExpiresAttoPubSubs < ActiveRecord::Migration
  def up
    add_column :pub_subs, :expires_at, :datetime
  end

  def down
    remove_column :pub_subs, :expires_at
  end
end
