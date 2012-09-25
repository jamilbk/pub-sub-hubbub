class AddDocumentToPubSubs < ActiveRecord::Migration
  def change
    add_column :pub_subs, :document, :text, :limit => 4294967295 # longtext
  end
end
