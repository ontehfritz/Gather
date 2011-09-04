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
  def question_responses
     @question = Question.find(params[:id])
     @responses = Response.find(:all, :conditions => ['question_id = ?', params[:id]])
     render :layout => "dialog"
  end
end
