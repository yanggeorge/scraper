class CreateItem < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.text  'spider_name'
      t.text  'item_name'
      t.text 'item_xpath'
      t.text 'item_reg'
      t.text 'item_type'
      t.text 'item_example'
    end
  end
end
