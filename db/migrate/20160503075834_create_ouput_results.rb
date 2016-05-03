class CreateOuputResults < ActiveRecord::Migration
  def change
    create_table :ouput_results do |t|
      t.text :robot_id
      t.text :ouput_result

      t.timestamps null: false
    end
  end
end
