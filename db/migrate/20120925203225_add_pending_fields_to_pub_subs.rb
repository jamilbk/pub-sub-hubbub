class AddPendingFieldsToPubSubs < ActiveRecord::Migration
  def change
    add_column :pub_subs, :verify_token, :string
    add_column :pub_subs, :topic, :string
  end
end
