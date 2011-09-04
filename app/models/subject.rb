class Subject < ActiveRecord::Base
  validates_presence_of :email
end
