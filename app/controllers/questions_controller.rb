class QuestionsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @questions = Question.where("section_id =?", params[:section_id]).order("sort_index")
    @section_id = params[:section_id]
    @section = Section.find(params[:section_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  def save_sort
    if params[:commit] == "Add Question"
      redirect_to(:action => "new", :id => params[:section_id], :types => "FreeForm")
      return
    elsif params[:commit] == "Done"
      @section = Section.find(params[:section_id])
      redirect_to(:controller => "sections",:action => "index", :statistician_id => @section.statistician_id)
      return
    end
    
    @order = params[:sort_order]
    @order.split(',').each_with_index do |question, i|
      Question.update(question, :sort_index => i+1)
    end
    questions = Question.where("section_id = ? and has_sub_question = 1", params[:section_id])
    questions.each do |q|
      suborder = params["sort_order_sub" + q.id.to_s]
      suborder.split(',').each_with_index do |question, i|
        Question.update(question, :sort_index => i+1)
      end
    end
    redirect_to(:action => "index", :section_id => params[:section_id])
  end

  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  def new
    @question = Question.new
    if params[:sub] == "new"
      @parent_question = Question.find(params[:id])
      #@parent_question_id =  @parent_question.id
      @question.section_id = @parent_question.section_id
      @question.is_sub = true
    else
      @question.section_id = params[:id]
      @question.is_sub = false
    end
    
    @question.types = params[:types]
    @question_type = @question.types.to_s
  end

  def edit
    @question = Question.find(params[:question_id])
    @question_type = @question.types.to_s
    @question_image = QuestionImage.where(:question_id => params[:question_id]).first
    
    if @question.is_sub == true
      sub_question = SubQuestion.find(:all, :conditions => ["question_sub_id = ?", @question.id]).first
      @trigger_answer = sub_question
      @parent_question = Question.find(sub_question.question_parent_id)
    end
  end

  def create
    @question = Question.new(params[:question])
       
    if params[:commit] == "Save"
      @question_new = @question.types.constantize.new(params[:question])
      
      if @question.is_sub
        subs = Question.where(:id => params[:parent_question_id]).first.sub_questions
        top_question = Question.find(:all, :conditions => ["id IN (?)", subs.map {|s| s.question_sub_id}]).sort_by{|question| question.sort_index}.last
            
        if top_question != nil && top_question.sort_index > 0
          @question_new.sort_index = top_question.sort_index + 1
        else
          @question_new.sort_index = 1
        end
      else
        top_question = Question.where(:section_id => @question.section_id).order("sort_index desc").first
       
        if top_question != nil && top_question.sort_index > 0
          @question_new.sort_index = top_question.sort_index + 1
        else
          @question_new.sort_index = 1
        end
      end
      
      if params[:trigger_answer] != nil && params[:trigger_answer] != ""
        @question_new.is_hidden = true
      else
        @question_new.is_hidden = false
      end
      #logger.debug "The object is #{@question}"
      respond_to do |format|
        if @question_new.save
          if @question_new.is_sub == true
            sub_question = SubQuestion.new
            sub_question.question_parent_id = params[:parent_question_id]
            sub_question.question_sub_id = @question_new.id
            sub_question.element_id = params[:trigger_answer]
            
            sub_question.save
            Question.update(params[:parent_question_id], :has_sub_question => true)
          end
          
          format.html { redirect_to(:action => "edit",:question_id => @question_new.id, :notice => 'Question was successfully created.') }
          format.xml  { render :xml => @question, :status => :created, :location => @question }
        else
          @question = @question_new
          format.html { render :action => "new" }
          format.xml  { render :xml => @question_new.errors, :status => :unprocessable_entity }
        end
      end
    elsif params[:commit] == "Cancel" || params[:commit] == "Done"
      redirect_to(:action => "index", :section_id => @question.section_id)
    elsif @question.is_sub
      redirect_to(:action => "new",:id => params[:parent_question_id],:types => @question.types, :sub => "new")
      return
    else
      redirect_to(:action => "new", :id => @question.section_id, :types => @question.types)
      return
    end
  end

  def update
    @question = Question.find(params[:id]).becomes(Question)
    
    if params[:commit] == "Cancel" || params[:commit] == "Done"
      redirect_to(:action => "index",:section_id => @question.section_id)
      return
    end
    
    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to(:action => "edit",:question_id => @question.id, :notice => 'Question was successfully created.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
  end
end