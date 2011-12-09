class ElementsController < ApplicationController
  before_filter :authenticate_user!
  def new  
    @element = Element.new
    @element.question_id = params[:question_id];
    
    render :layout => "dialog"
  end
  
  def create
    if params[:commit] == "Cancel"
      redirect_to(:controller => "elements", :action => "index",:question_id => 0) 
      return
    end
  
    @element = Element.new(params[:element])
      
    if @element.score == nil 
      @element.score = 0
    end 
      
    top_element = Element.where(:question_id => @element.question_id).order("sort_index desc").first;
      
    if top_element != nil  && top_element.sort_index > 0
      @element.sort_index = top_element.sort_index + 1
    else
      @element.sort_index = 1
    end
    
    respond_to do |format|
      if @element.save
        format.html { redirect_to(:controller => "elements", :action => "index",:question_id => @element.question_id, :notice => 'Answer was successfully created.') }
        format.xml  { render :xml => @element, :status => :created, :location => @element }
      else
        format.html { render :action => "new", :layout => "dialog" }
        format.xml  { render :xml => @element.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def index
    #this controller closes dialogs, check the view for details
    #this needs to change to a different close_dialog
  end
   
  def destroy
    @element = Element.find(params[:id])
    element_question_id = @element.question_id
    @element.destroy
    question = Question.find(element_question_id)

    respond_to do |format|
      format.html {redirect_to(edit_question_path(question.becomes(Question)), :notice => 'Answer was successfully deleted.') }
      format.xml  { head :ok }
    end
  end
  
  def edit
    @element = Element.find(params[:id])
    render :layout => "dialog"
  end

  def update
    @element = Element.find(params[:id])

    respond_to do |format|
      if @element.update_attributes(params[:element])
        format.html { redirect_to(:controller => "elements", :action => "index",:question_id => @element.question_id, :notice => 'Answer was successfully created.')}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end
end
