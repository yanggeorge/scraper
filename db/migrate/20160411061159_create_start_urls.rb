class CreateStartUrls < ActiveRecord::Migration
  def change
    create_table :start_urls do |t|
      t.text :url_name
      t.text :url_value
      t.text :url_response
      t.text :spider_name

      t.timestamps null: false
    end
  end
end
