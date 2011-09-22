class SkipLogic < ActiveRecord::Base
  validates_presence_of :element
  belongs_to :question
  belongs_to :element
  belongs_to :section
end
