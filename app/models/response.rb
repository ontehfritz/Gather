class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :subject
  belongs_to :element
  
  def self.clear_section_responses(subject_id, section)
    Response.delete_all(["subject_id = ? and question_id in (?)", subject_id, section.questions.map {|q| q.id}])
  end
end
