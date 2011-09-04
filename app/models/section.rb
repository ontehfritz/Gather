class Section < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :statistician
  has_many :questions, :dependent => :destroy 
  
  def question_count_up_to_this_section(statistician_id)
    sections = Section.where("statistician_id = ?", statistician_id).sort_by{|section| section.sort_index}
    question_count = 0
    
    sections.each do |s|
      if s.id == self.id
        return question_count
      else
        question_count += s.questions.find_all{|x| x.is_sub == false}.size
      end
    end
    return question_count
  end
end
