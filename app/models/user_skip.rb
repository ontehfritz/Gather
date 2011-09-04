class UserSkip < ActiveRecord::Base
  belongs_to :subject
  belongs_to :question
  belongs_to :section
end
