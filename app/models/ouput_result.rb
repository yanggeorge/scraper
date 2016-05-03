class OuputResult < ActiveRecord::Base
  validates :robot_id , presence: true
  validates :ouput_result, presence: true
end
