class OrderAddress < ActiveRecord::Base
  belongs_to :source_address, class_name: "Address"
end
