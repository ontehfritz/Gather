class SurveysController < ApplicationController
  def declined
    @statistician = Statistician.find(params[:id])
    reset_session
    render :layout => "statistician"
  end
  
  def power
    @statistician = Statistician.find(params[:id])
    reset_session 
    render :layout => "statistician"
  end 
  
  def finish
    if session[:subject_id] == nil
      raise "Your session has expired or an error has occured"
    end
    
    @statistician = Statistician.find(params[:id])
    completed = UserCompletedSurvey.new(:subject_id => session[:subject_id], 
                                                    :statistician_id => @statistician.id)
    completed.save
    
    UserSkip.delete_all(["subject_id = ? and statistician_id = ?", session[:subject_id], @statistician.id])
    reset_session
    render :layout => "statistician"
  end
  
  def begin
    @statistician = Statistician.find(params[:id])
    if @statistician.power != true
      redirect_to(:action => "power", :id => @statistician.id)
      return
    end
    if session[:is_authenticated] == nil
      session[:is_authenticated] = false
    end
    
    if @statistician.is_password_required == true  && session[:is_authenticated] == false
       redirect_to(:action => "authenticate", :id => @statistician.id)
       return
    end
    
    if @statistician.is_id_required == true && session[:is_authenticated] == false
       redirect_to(:action => "subject_authenticate", :id => @statistician.id)
       return
    end
    
    if params[:commit] == "Agree"
      #logger.debug "commited"
      if @statistician.is_anonymous == true
        #logger.debug "anonymous"
        new_subject = Subject.new(:first_name => "Anonymous", :is_anonymous => true, :email => "Anonymous")
        if new_subject.save
          session[:subject_id] = new_subject.id
          session[:checksum] = Digest::MD5.hexdigest("#{new_subject.id}#{@statistician.id}")
          redirect_to(:action => "section", :id => Section.find(:all, 
              :conditions => ["statistician_id = (?)", @statistician.id], :order => "sort_index").first.id)
          return
        else
          #format.html { render :action => "begin" }
          logger.debug new_subject.errors
        end
      else
        redirect_to(:action => "information", :id => Section.find(:all, 
              :conditions => ["statistician_id = (?)", @statistician.id], :order => "sort_index").first.id)
        
        return
      end
    elsif params[:commit] == "No thanks"
      redirect_to(:action => "declined", :id => @statistician.id)
      return
    end
    render :layout => "statistician"
  end
  
  def information
    section = Section.find(params[:id])
    @statistician = section.statistician
    if params[:commit] == "Continue"
      @new_subject = Subject.new(params[:subject])
      if @new_subject.save
        session[:subject_id] = @new_subject.id
        session[:checksum] = Digest::MD5.hexdigest("#{@new_subject.id}#{section.statistician.id}")
        redirect_to(:action => "section", :id => params[:id])
        return
      else
        render :layout => "statistician"
        return
      end
    elsif params[:commit] == "Cancel"
      #section = Section.find(params[:id])
      redirect_to(:action => "begin", :id => section.statistician.id)
      return
    end
    @new_subject = Subject.new
    render :layout => "statistician"
  end
  
  def subject_authenticate
    @error = false
    @statistician = Statistician.find(params[:id])
     
    if params[:commit] == "Continue"
      begin
        @subject = Subject.find(params[:subject_id])
        if @subject.password == params[:pass]
          session[:subject_id] = @subject.id
          session[:is_authenticated] = true
          redirect_to(:action => "begin", :id => @statistician.id)
          return
        else
          @error = true
          session[:is_authenticated] = false
        end
      rescue
        @error = true
        session[:is_authenticated] = false
      end
    end
    
    render :layout => "statistician"
  end
  
  def authenticate
    @error = false
    @statistician = Statistician.find(params[:id])
     
    if params[:commit] == "Continue"
      if @statistician.unlock_key == params[:pass]
        session[:is_authenticated] = true
        redirect_to(:action => "begin", :id => @statistician.id)
        return
      else
        @error = true
        session[:is_authenticated] = false
      end
    end
    
    render :layout => "statistician"
  end
  
  def section
    if session[:subject_id] == nil
      raise "Your session has expired or an error has occured"
    end
    @section = Section.find(params[:id])
    @statistician = @section.statistician
    
    if session[:checksum] == nil || 
          session[:checksum] != Digest::MD5.hexdigest("#{session[:subject_id]}#{@section.statistician_id}")
      raise "Your session has expired or an error has occured"
    end
    
    render :layout => "statistician"
  end
  
  def save
    if session[:subject_id] == nil
      raise "Your session has expired or an error has occured"
    end
    
    @section = Section.find(params[:id])
    @statistician = @section.statistician
    @sections = Section.find(:all, :conditions => ["statistician_id = (?)", @section.statistician_id], :order => "sort_index")
    @skips = SkipLogic.where("question_id in (?)", @section.questions.map {|q| q.id})
    
    @section.questions.each do |q|
      UserSkip.delete_all(["subject_id = ? and question_id = ?", session[:subject_id], q.id])
    end
    answered = Array.new
    Response.delete_all(["subject_id = ? and question_id in (?)", session[:subject_id], @section.questions.map {|q| q.id}])
    #This saving response code works well and is reliable. However the rigidness of the code 
    #is a pile shit. This design needs to change and will change next release
    #thinking different response types with overwritten save methods
    if params[:questions] != nil
      params[:questions].values.each do |q|
        if q[:multiple_answer] == "true"
          flag_answered = false 
          if q[:answer_id] != nil
            q[:answer_id].values.each do |a|
              if a[:id] == nil and a[:answer] != ""
                response = Response.new(:question_id => q[:question], 
                  :answer_text => a[:answer], :subject_id => session[:subject_id], :element_id => a[:id])
                response.save 
              elsif a[:id] != nil
                if (q[:type] == "Scale" && a[:answer] != nil) || (q[:type] == "Likert" && a[:answer] != nil)
                  response = Response.new(:question_id => q[:question], 
                    :answer_text => a[:answer], :subject_id => session[:subject_id], :element_id => a[:id])
                  flag_answered = true
                  response.save
                elsif q[:type] == "MultipleChoiceCheckbox"
                  response = Response.new(:question_id => q[:question], 
                    :answer_text => a[:answer], :subject_id => session[:subject_id], :element_id => a[:id])
                  flag_answered = true
                  response.save
                end
              end
            end
          end
          if flag_answered == true
            answered.push q[:question]  
          end  
        else
           @skips.each do |skip|
                if skip.types == "Skip" && q[:question] == skip.question_id.to_s && q[:answer_id] == skip.element_id.to_s
                  user_skip = UserSkip.new(:subject_id => session[:subject_id],:question_id => skip.question_id, 
                    :section_id => skip.section_id, :statistician_id => @section.statistician_id)
                  user_skip.save
                end
              end
          response = Response.new(:question_id => q[:question], 
            :answer_text => q[:answer], :subject_id => session[:subject_id], :element_id => q[:answer_id])
          if (q[:answer_id] != "" && q[:answer_id] != nil) || (q[:answer] != nil && q[:answer] != "")
            answered.push q[:question]
            response.save
          end
        end
      end
    end
    #end of shit that needs to be changed
    
    @errors = false
    logger.debug "answered: #{answered.inspect}"
    
    @section.questions.each do |q|
      if q.is_answer_required == true
        required_error = true
      else
        required_error = false
      end
      answered.each do |a|
        if q.id.to_s == a
          #logger.debug "match found"
          required_error = false
        end
      end
      if required_error == true 
        @errors = true
        q.errors.add(:is_answer_required, "Required")
      end
    end
    
    @user_skips = UserSkip.find(:all, :conditions => ["subject_id = 
      ? and statistician_id = ?", session[:subject_id], @section.statistician_id])

    @user_skips.each do |sk|
      @sections.delete_if {|sec| sec.id == sk.section_id}
    end
    
    if @errors == false
      if params[:commit] == "Next"
         if @sections.index(@section) + 1 >= @sections.length
           redirect_to(:action => "finish", :id => @section.statistician.id)
           return
         end
         redirect_to(:action => "section",:id => @sections[@sections.index(@section) + 1].id)
      elsif params[:commit] == "Back"
         redirect_to(:action => "section",:id => @sections[@sections.index(@section) - 1].id)
      elsif params[:commit] == "Finish"
         redirect_to(:action => "finish", :id => @section.statistician.id)
      end
    else
      render :action => "section", :layout => "statistician"
    end
  end
end
