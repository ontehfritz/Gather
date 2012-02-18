class SurveysController < ApplicationController
  #Respondent declines to fill out survey 
  def declined
    @statistician = Statistician.find(params[:id])
    reset_session #kill the current session
    render :layout => "statistician"
  end
  
  #Respondent has completed the survey, Get completed survey information
  #If using a subject logon, this will alert the subject they already filled
  #out the survey
  def completed
    @statistician = Statistician.find(params[:id])
    @complete = UserCompletedSurvey.find_by_subject_id_and_statistician_id(session[:subject_id],@statistician.id)
    reset_session
    render :layout => "statistician"
  end
  
  #If the survey has not been turned get redirected here
  def power
    @statistician = Statistician.find(params[:id])
    reset_session 
    render :layout => "statistician"
  end 
  
  #once survey is complete this method is executed
  def finish
    #check if the session is still valid or the survey is beening accessed correcty
    #this session variable must be valid throughout each step of the survey
    if session[:subject_id] == nil
      raise "Your session has expired or an error has occured"
    end
    
    @statistician = Statistician.find(params[:id])
    #record completion of survey, if this does not occur survey will not be recognized as 
    #complete
    completed = 
          UserCompletedSurvey.new(:subject_id => session[:subject_id], 
                                                :statistician_id => @statistician.id)
    
    respond_to do |format|                                     
      if completed.save
        #delete any skip logic information for this repondant, if any. This is only needed if survey is 
        #still being used
        UserSkip.delete_all(["subject_id = ? and statistician_id = ?", 
                                          session[:subject_id], @statistician.id])
        reset_session
        format.html { render :layout => "statistician" }
      else
        format.html { render :layout => "statistician" }
      end
    end
  end
  
  #before survey begins display disclamer/introduction to survey
  #also perform a number of checks if any other action needs to 
  #be taken such as authentication, subject check etc ...
  def begin
    @statistician = Statistician.find(params[:id])
    
    #if the survey is not turned on, redirect to power
    #action notfiying the respondent that the survey
    #needs to be turned on.
    if @statistician.power != true
      redirect_to(:action => "power", :id => @statistician.id)
      return
    end
    
    #intialize session if not intialized
    #this is used for password protected surveys
    if session[:is_authenticated] == nil
      session[:is_authenticated] = false
    end
    
    #intialize session if not intialized
    #this is used when a survey requires a subject to login
    if session[:is_subject_authenticated] == nil
      session[:is_subject_authenticated] = false
    end
    
    #if survey is password protected and have not authenticated
    #redirect to authentication page
    if @statistician.is_password_required == true  && session[:is_authenticated] == false
       redirect_to(:action => "authenticate", :id => @statistician.id)
       return
    end
    #redirect to subject authentication if survey has enabled it
    if @statistician.is_id_required == true && session[:is_subject_authenticated] == false
       redirect_to(:action => "subject_authenticate", :id => @statistician.id)
       return
    end
    
    #did respondent click agree
    if params[:commit] == "Agree"
      #logger.debug "commited"
      
      #if the survey is anonymous make an entry into the subject table
      if @statistician.is_anonymous == true
        #logger.debug "anonymous"
        new_subject = Subject.new(:first_name => "Anonymous", :is_anonymous => true, :email => "Anonymous")
        
        #skip validation
        if new_subject.save(:validate => false)
          session[:subject_id] = new_subject.id
          #this is used so users cannot jump to other surveys after authentication
          #if the checksum fails then they are messing around between surveys
          session[:checksum] = Digest::MD5.hexdigest("#{new_subject.id}#{@statistician.id}")
          redirect_to(:action => "section", :id => Section.find(:all, 
              :conditions => ["statistician_id = (?)", @statistician.id], :order => "sort_index").first.id)
          return
        else
          #format.html { render :action => "begin" }
          logger.debug new_subject.errors
        end
      #if the survey is not anonymous collect user information
      elsif @statistician.is_id_required == false
        redirect_to(:action => "information", :id => Section.find(:all, 
              :conditions => ["statistician_id = (?)", @statistician.id], :order => "sort_index").first.id)
        
        return
      #if subject login is required and the subject authenticated check if subject
      #has already completed this survey
      elsif @statistician.is_id_required == true && session[:is_subject_authenticated] == true
          if UserCompletedSurvey.find_by_subject_id_and_statistician_id(session[:subject_id],@statistician.id) != nil
             redirect_to(:action => "completed", :id => @statistician.id)
             return
          end
          #create the checksum 
          session[:checksum] = Digest::MD5.hexdigest("#{session[:subject_id]}#{@statistician.id}")
          redirect_to(:action => "section", :id => Section.find(:all, 
              :conditions => ["statistician_id = (?)", @statistician.id], :order => "sort_index").first.id)
          return
      end
    #if the user has declined redirect to declined page
    elsif params[:commit] == "No thanks"
      redirect_to(:action => "declined", :id => @statistician.id)
      return
    end
    render :layout => "statistician"
  end
  
  #if the survey is not anonymous respondents have
  #to fill in their informations
  def information
    section = Section.find(params[:id])
    @statistician = section.statistician
    
    #if the respondent continues, enter the information as a subject
    #this can be later used to have this respondant return
    if params[:commit] == "Continue"
      @new_subject = Subject.new(params[:subject]) 
      @new_subject.password = Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}"))[0..7]
      @new_subject.identifier = Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}"))[0..7]
      @new_subject.is_anonymous = false
      
      if @new_subject.save
        session[:subject_id] = @new_subject.id
        session[:checksum] = Digest::MD5.hexdigest("#{@new_subject.id}#{section.statistician.id}")
        redirect_to(:action => "section", :id => params[:id])
        return
      else #tsk tsk make better
        render :layout => "statistician"
        return
      end
    #if respondant cancels redirect to the beginning of the survey
    elsif params[:commit] == "Cancel"
      #section = Section.find(params[:id])
      redirect_to(:action => "begin", :id => section.statistician.id)
      return
    end
    @new_subject = Subject.new
    render :layout => "statistician"
  end
  
  #used to authenticate subjects
  def subject_authenticate
    @statistician = Statistician.find(params[:id])
     
    if params[:commit] == "Continue"
      begin
        #simply authentication, passcode per subject
        #key must be unique. If stronger authentication is 
        #needed this will have to change. For lab scenerios and studies
        #this should be fine.
        @subject = Subject.where(:password => params[:pass]).first
        if !@subject.nil?
          session[:subject_id] = @subject.id
          session[:is_subject_authenticated] = true
          redirect_to(:action => "begin", :id => @statistician.id)
          return
        else
          flash[:notice] = "Password and/or Respondant ID is incorrect. Please try agian.";
          session[:is_subject_authenticated] = false
        end
      rescue
        flash[:notice] = "Error has occured";
        session[:is_authenticated] = false
      end
    end
    
    render :layout => "statistician"
  end
  
  #This is for survey authentication 
  #Very simple passcode is used. 
  def authenticate
    @statistician = Statistician.find(params[:id])
     
    if params[:commit] == "Continue"
      if @statistician.unlock_key == params[:pass]
        session[:is_authenticated] = true
        redirect_to(:action => "begin", :id => @statistician.id)
        return
      else
        flash[:notice] = "Passcode is not valid for this survey";
        session[:is_authenticated] = false
      end
    end
    
    render :layout => "statistician"
  end
  
  #this renders a section of the survey
  def section
    #make sure a anonymous respondent or subject is active before continuing
    if session[:subject_id] == nil
      raise "Your session has expired or an error has occured"
    end
    
    @section = Section.find(params[:id])
    @statistician = @section.statistician
    
    #check if this is a valid session 
    #meaning you are authorized and are not trying to bypass authenication on other surveys
    if session[:checksum] == nil || 
          session[:checksum] != Digest::MD5.hexdigest("#{session[:subject_id]}#{@section.statistician_id}")
      raise "Your session has expired or an error has occured"
    end
    
    render :layout => "statistician"
  end
  
  #this method saves information entered by the respondent
  #also it deterimines the paths the survey will take with skip logic
  def save
    #once again check if we have a subject active or session hasn't expired
    if session[:subject_id] == nil
      raise "Your session has expired or an error has occured"
    end
    
    @section = Section.find(params[:id])
    @statistician = @section.statistician
    @sections = Section.find(:all, :conditions => ["statistician_id = (?)", @section.statistician_id], :order => "sort_index")
    #skip logic determines which page will be displayed next
    #retrieve all the skip logics
    @skips = SkipLogic.where("question_id in (?)", @section.questions.map {|q| q.id})
    
    #delete any skip logic triggered for current section
    UserSkip.clear_section(session[:subject_id], @section)
    #clear the responses for new answers
    Response.clear_section_responses(session[:subject_id], @section)
    
    answered = Array.new
    @errors = false
     
    if params[:questions] != nil #one or more questions have been answered
      # loop through each question
      params[:questions].values.each do |q|
        # eval the type calling that save_response method defined on the model object 
        # The save_response method will return a bool if the 
        # respondant successfully has answered the question
        if !eval(q[:type]).save_response(q,session[:subject_id])
          is_q = @section.questions.select {|q1| q1.id.to_s == q[:question]}.first
          if is_q.is_answer_required
            @errors = true
            is_q.errors.add(:is_answer_required, "Required")
          end
        end
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
  
  def css_style
    @statistician = Statistician.find(params[:id])
    
    respond_to do |format|
      format.css { render :css => "css_style", :content_type => "text/css", :layout => nil}
    end
  end
end
