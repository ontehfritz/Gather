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

  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  def new
    @question = params[:type].constantize.new
    if params[:sub] == "new"
      @parent_question = Question.find(params[:id])
      #@parent_question_id =  @parent_question.id
      @question.section_id = @parent_question.section_id
      @question.is_sub = true
    else
      @question.section_id = params[:id]
      @question.is_sub = false
    end
  end

  def edit
    @question = Question.find(params[:id])
    @question_image = QuestionImage.where(:question_id => params[:id]).first
    
    if @question.is_sub == true
      sub_question = SubQuestion.find(:all, :conditions => ["question_sub_id = ?", @question.id]).first
      @trigger_answer = sub_question
      @parent_question = Question.find(sub_question.question_parent_id)
    end
  end

  def create
    @question = params[:question][:type].constantize.new(params[:question])
       
    if params[:commit] == "Save"
      @question_new = @question.type.constantize.new(params[:question])
      @question_new.question_type_id = QuestionType.find(:all,:conditions => {:type_name => @question_new.type}).first.id
      
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
          
          format.html { redirect_to(edit_question_url(@question_new), :notice => 'Question was successfully created.') }
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
      redirect_to(:action => "new",:id => params[:parent_question_id],:type => @question.class.name, :sub => "new")
      return
    else
      redirect_to(:action => "new", :id => @question.section_id, :type => @question.class.name)
      return
    end
  end

  def update
    @question = Question.find(params[:id])
    
    if params[:commit] == "Cancel" || params[:commit] == "Done"
      redirect_to(:action => "index", :section_id => @question.section_id)
      return
    end
    
    respond_to do |format|
      if @question.update_attributes(params[:question])
        @order = params[:sort_order]
        if @order != nil
          @order.split(',').each_with_index do |element, i|
              Element.update(element, :sort_index => i+1)
          end
        end
        
        format.html { redirect_to(edit_question_path(@question), :notice => 'Question was successfully Updated.') }
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
    
    questions = []
    if @question.is_sub 
      parent_id = SubQuestion.where('question_sub_id = ?', @question.id).first.question_parent_id
      questions = Question.find(parent_id).questions.order("sort_index")
    else
      questions = Section.find(@question.section.id).questions.order("sort_index")
    end     
    
    i = 1
    questions.each do |q| 
      q.sort_index = i 
      q.save 
      i = i + 1
    end
    
    respond_to do |format|
      format.html { redirect_to(section_questions_url(@question.section)) }
      format.xml  { head :ok }
    end
  end
end
