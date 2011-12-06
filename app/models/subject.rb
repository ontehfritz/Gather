class Subject < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :first_name
  validates_presence_of :password
  validates :password, :uniqueness => true
  validates :identifier, :uniqueness => true
  has_many :responses
  has_many :user_completed_surveys
  
  def full_name 
    "#{self.first_name} #{self.middle_name} #{self.last_name}" 
  end
end
