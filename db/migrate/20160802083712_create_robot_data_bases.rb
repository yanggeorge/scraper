class CreateRobotDataBases < ActiveRecord::Migration
  def change
    create_table :robot_data_bases do |t|
      t.text 'robot_id'
      t.text 'robot_name'
      t.text 'deleted'
      t.text 'robot_def'
    end
  end
end
