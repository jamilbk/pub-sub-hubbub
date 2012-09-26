class AddDocumentToPubSubs < ActiveRecord::Migration
  def change
    case connection.adapter_name.downcase.to_sym
    when :mysql # dammit mysql
      add_column :pub_subs, :document, :text, :limit => 4294967295 # longtext
    else
      add_column :pub_subs, :document, :text
    end
  end
end
