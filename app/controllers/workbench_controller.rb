require 'csv'
class WorkbenchController < ApplicationController
  before_filter :authenticate_user!#, :except => [:some_action_without_auth]
  
  def close
    #close dialog
  end
  
  def index
    @statisticians = nil
    
    if params[:id] == nil
      @statisticians = Statistician.all
    else
      @statisticians = Statistician.find(:all, :conditions => ['name LIKE ?', params[:id]+'%' ])
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @statisticians }
    end
  end
  
  def power
    @statistician = Statistician.find(params[:id])
    #@response_count =  UserCompletedSurvey.count(:conditions => ['statistician_id = ?', @statistician.id])
    
    if @statistician.power == true
      Statistician.update(@statistician.id, :power => false)
    else
      Statistician.update(@statistician.id, :power => true)
    end
    
    redirect_to(:action => "index",:id => nil)
  end
  
  def link
    @statistician = Statistician.find(params[:id])
  end
  
  def results
    @statistician = Statistician.find(params[:id])
    @statistician.sections.each do |s|
      if @questions != nil then 
        @questions = @questions + s.questions
      else
        @questions = s.questions
      end
      #s.questions.each do |q|
        #if @results != nil then 
        #  @results = @results + q.responses
        #else 
        #  @results = q.responses
        #end
      #end
    end
  end
  
  def export_results
    @headers = Array.new
    @headers.push("Subject_id", "FirstName", "LastName", "DateCompleted")
    @statistician = Statistician.find(params[:id])
    @responses = UserCompletedSurvey.find(:all, :conditions => {:statistician_id => params[:id]})
    @statistician.sections.each do |s|
      if @questions != nil then 
        @questions = @questions + s.questions
      else
        @questions = s.questions
      end
    end
    
    @questions.each do |q|
       if q.question_type.is_multi_answer == true
          q.elements.each do |answer|
            @headers.push("#{q.question_text}-#{answer.element_text}")
          end
          if q.option_id  != nil and q.option.id == 3
            @headers.push("#{q.question_text}-#{q.option.name}")
          end
           
       else
          @headers.push(q.question_text)
          if q.option_id  != nil and q.option.id == 3
            @headers.push("#{q.question_text}-#{q.option.name}")
          end
       end
    end
    
    csv_string = CSV.generate do |csv| 
        csv << @headers
        #row = Array.new
        @responses.each do |r|
          row = Array.new
          row.push(r.subject.id)
          row.push(r.subject.first_name)
          row.push(r.subject.last_name)
          row.push(r.created_at)
          @questions.each do |q|
            if q.question_type.is_multi_answer == true
              q.elements.each do |answer|
                 response = Response.find(:all, :conditions => {:question_id => q.id, :element_id => answer.id, :subject_id => r.subject.id}).first
                 if response == nil
                   row.push(nil)
                 else
                   if response.answer_text != nil and response.answer_text != ''
                      row.push(response.answer_text)
                   else
                      row.push(response.element.element_text)
                   end
                 end
                 #response == nil ? row.push(nil) : row.push(response.element.element_text)
                 #row.push(response.element_id)
              end
              if q.option_id == 3 
                response = Response.where("question_id = ? and subject_id = ? and answer_text IS NOT NULL", q.id,r.subject.id).first
                if response != nil
                  row.push(response.answer_text)
                else
                  row.push(nil)
                end
              end
            else
              
              logger.debug "type : #{q.type.downcase}"
              if q.type.downcase == "freeform"
                response = Response.where("question_id = ? and subject_id = ?", q.id,r.subject.id).first
                row.push(response == nil ? nil : response.answer_text)
              else
                response = Response.where("question_id = ? and subject_id = ? and element_id IS NOT NULL", q.id,r.subject.id).first
                if response != nil
                  if response.answer_text != nil
                    row.push(response.answer_text)
                  else
                    row.push(response.element.element_text)
                  end
                else
                  row.push(nil)
                end
              end
           
              if q.option_id == 3 
                response = Response.where("question_id = ? and subject_id = ? and answer_text IS NOT NULL and element_id IS NULL", q.id,r.subject.id).first
                if response != nil
                  row.push(response.answer_text)
                else
                  row.push(nil)
                end
              end
                 #response = Response.find(:all, :conditions => {:question_id => q.id, :element_id => q.elements.first != nil ? q.elements.first.id : nil })
                 #response != nil ? row.push(response.element_id) : Response.find(:all, :conditions => {:question_id => q.id})
            end
          end
          csv << row
        end
        
    end
    send_data csv_string, 
            :type => 'text/csv; charset=iso-8859-1; header=present', 
            :disposition => "attachment; filename=results.csv" 
  end
  
  def question_responses
     @question = Question.find(params[:id])
     @responses = Response.find(:all, :conditions => ['question_id = ?', params[:id]])
     render :layout => "dialog"
  end
  
  def list_results
    @completed = UserCompletedSurvey.paginate(:conditions =>['statistician_id =?', params[:id]], :page => params[:page], :per_page => 20)
  end
  
  def view_survey
    @section = Section.find(params[:section_id])
    @subject_id = params[:subject_id]
    @statistician = @section.statistician
    session[:subject_id] = @subject_id
    @sections = Section.find(:all, :conditions => ["statistician_id = (?)", @section.statistician_id], :order => "sort_index")
    
    if params[:commit] == "Next"
         if @sections.index(@section) + 1 >= @sections.length
           redirect_to(:action => "list_results", :id => @section.statistician.id, :page => 1)
           return
         end
         redirect_to(:action => "view_survey",:section_id => @sections[@sections.index(@section) + 1].id, :subject_id => @subject_id)
         return 
    elsif params[:commit] == "Back"
      redirect_to(:action => "view_survey",:section_id => @sections[@sections.index(@section) - 1].id, :subject_id => @subject_id)
      return
    elsif params[:commit] == "Finish"
      redirect_to(:action => "list_results", :id => @section.statistician.id, :page => 1)
      return
    end
     
    render :layout => "statistician"
  end  
end
