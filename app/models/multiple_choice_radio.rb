class MultipleChoiceRadio < Question
  def self.save_response(params, subject_id)
     answered = false
     if (params[:answer_id] != "" && params[:answer_id] != nil) || (params[:answer] != nil && params[:answer] != "")
       response = Response.new :question_id => params[:question], 
                                :answer_text => params[:answer], :subject_id => subject_id, :element_id => params[:answer_id]
       response.save
       
       #q[:question] == skip.question_id.to_s && q[:answer_id] == skip.element_id.to_s
       
       
       if params[:additional_text] != nil and params[:additional_text] != "" 
         response = Response.new :question_id => params[:question], 
                                      :answer_text => params[:additional_text], :subject_id => subject_id
         response.save
       end
       
       #Skip logic trigger
       skip = SkipLogic.find(:all, :conditions => ["question_id = ? and element_id = ?", params[:question], params[:answer_id]]).first
       if skip != nil
         section = Section.find(skip.section_id)
         userSkip = UserSkip.new :subject_id => subject_id, :question_id => skip.question_id, 
                           :section_id => skip.section_id, :statistician_id => section.statistician_id
         userSkip.save
       end
       answered = true
     end
     #****************# 
     answered        
  end
end