class FreeForm < Question
  def self.save_response(params, subject_id)
     answered = false
     if params[:answer] != nil
       response = Response.new(:question_id => params[:question], :answer_text => params[:answer], :subject_id => subject_id, :element_id => params[:id])
       response.save
       answered = true
     end
     answered
  end
end