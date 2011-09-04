class SkipLogic < ActiveRecord::Base
  belongs_to :question
  belongs_to :element
  belongs_to :section
end
