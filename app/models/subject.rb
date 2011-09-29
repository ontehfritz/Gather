class Subject < ActiveRecord::Base
  validates_presence_of :email
  has_many :responses
  has_many :user_completed_surveys
end
