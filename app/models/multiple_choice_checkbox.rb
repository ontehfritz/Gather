class MultipleChoiceCheckbox < Question
   def self.save_response(params, subject_id)
     answered = false
     if params[:answer_id] != nil
       params[:answer_id].values.each do |a|
         if a[:id] != nil
           response = Response.new :question_id => params[:question], 
                         :answer_text => a[:answer], :subject_id => subject_id, :element_id => a[:id]
           response.save
           answered = true; 
         end
       end
       
       if params[:additional_text] != nil and params[:additional_text] != "" 
         response = Response.new :question_id => params[:question], 
                                      :answer_text => params[:additional_text], :subject_id => subject_id
         response.save
       end 
     end  
     answered       
  end
end