class State < ActiveRecord::Base
  has_many :cities, inverse_of: :state
end
