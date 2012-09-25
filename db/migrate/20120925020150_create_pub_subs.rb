class CreatePubSubs < ActiveRecord::Migration
  def change
    create_table :pub_subs do |t|
      t.string :feed_url

      t.timestamps
    end
  end
end
