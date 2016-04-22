class Item < ActiveRecord::Base
  validates :spider_name, presence: true, length: {:maximum => 40}
  validates :item_name, length: {:maximum => 20}
  validates :item_xpath,length: {:maximum => 100}
  validates :item_reg,length: {:maximum => 100}
  validates :item_type,length: {:maximum => 10}
  validates :item_example,length: {:maximum => 1000}
  validates :start_url,length: {:maximum => 100}
end

if __FILE__==$0 then

end