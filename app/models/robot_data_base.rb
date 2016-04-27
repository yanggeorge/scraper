class RobotDataBase < ActiveRecord::Base
  validates :robot_id ,presence: true,length:  {:maximum => 40}
  validates :robot_name, presence: true, length:  {:maximum => 100}
  validates :deleted , presence: true
  validates :robot_def, presence: true
end
