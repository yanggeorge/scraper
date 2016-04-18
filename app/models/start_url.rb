class StartUrl < ActiveRecord::Base
  validates :url_name, presence: true, length: {:maximum => 30}
  validates :url_value, length: {:maximum => 100}
  validates :spider_name  ,length: {:maximum => 40}
end
