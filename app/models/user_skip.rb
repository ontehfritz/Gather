#This is used to keep track of what skip logic has been triggered
#It tells gather which sections to skip per user
class UserSkip < ActiveRecord::Base
  belongs_to :subject
  belongs_to :question
  belongs_to :section
  
  #this clears user_skips for the section
  def self.clear_section(subject_id, section)
    #this can be optimized, can't remeber why I did it this way
    #I think this is because the section_id is not the section id of
    #the question, but the section to skip, the reason for clearing 
    #all the questions in current section; is the respondant can change 
    #the answers and not trigger skip logic
    section.questions.each do |q|
      UserSkip.delete_all(["subject_id = ? and question_id = ?", subject_id, q.id])
    end
  end
end
