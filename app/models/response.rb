class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :subject
  belongs_to :element
end
