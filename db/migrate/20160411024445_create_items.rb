class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.text  'name'
      t.text  'item_name'
      t.text 'item_xpath'
      t.text 'item_reg'
      t.text 'item_type'
    end
  end
end

