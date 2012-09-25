class AddStatusToPubSubs < ActiveRecord::Migration
  def change
    add_column :pub_subs, :status, :string
  end
end
