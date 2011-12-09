class SkipLogicsController < ApplicationController
  before_filter :authenticate_user!
  def new 
    @skip_logic = SkipLogic.new
    @skip_logic.question_id = params[:question_id]
    @skiplogictypes = SkipLogicType.find(:all)
    
    render :layout => "dialog"
  end
  
  def create
      @skip_logic = SkipLogic.new(params[:skip_logic])
      
      respond_to do |format|
      if @skip_logic.save
         format.html { redirect_to(:controller => "skip_logics", :action => "index",:question_id => @skip_logic.question_id) }
         format.xml  { render :xml => @skip_logic, :status => :created, :location => @skip_logic }
      else
          format.html { render :action => "new",:layout => "dialog" }
          format.xml  { render :xml => @skip_logic.errors, :status => :unprocessable_entity }
       end
     end
  end
  
  def edit
    @skip_logic = SkipLogic.find(params[:id])
    render :layout => "dialog"
  end
  
  def update
    @skip_logic = SkipLogic.find(params[:id])

    respond_to do |format|
      if @skip_logic.update_attributes(params[:skip_logic])
        format.html { redirect_to(:controller => "skip_logics", :action => "index",:question_id => @skip_logic.question_id, :notice => 'Skip Logic was successfully created.')}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" , :layout => "dialog"}
        format.xml  { render :xml => @skip_logic.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @skip_logic = SkipLogic.find(params[:id])
    question_id = @skip_logic.question_id
    @skip_logic.destroy
    question = Question.find(question_id)

    respond_to do |format|
      format.html {redirect_to(edit_question_path(question), :notice => 'Answer was successfully deleted.') }
      format.xml  { head :ok }
    end
  end
end
