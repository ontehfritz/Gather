class Scale < Question
   def self.save_response(params, subject_id)
     answered = false
     
     params[:answer_id].values.each do |a|
       if a[:answer] != nil
          response = Response.new :question_id => params[:question], 
                          :answer_text => a[:answer], :subject_id => subject_id, :element_id => a[:id]
          response.save
          answered = true
       end
     end
     answered   
  end
end