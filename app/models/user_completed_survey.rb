class UserCompletedSurvey < ActiveRecord::Base
  belongs_to :subject
  belongs_to :statistician


end
