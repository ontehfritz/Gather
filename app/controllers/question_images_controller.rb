class QuestionImagesController < ApplicationController
  # GET /question_images
  # GET /question_images.xml
  def index
    #this controller closes dialogs, check the view for details
    #this needs to change to a different close_dialog
  end

  # GET /question_images/1
  # GET /question_images/1.xml
  def show
    @question_image = QuestionImage.find(params[:id])

    @image = @question_image.image_data
    send_data @image, :type     => @question_image.content_type, 
                     :filename => @question_image.file_name, 
                     :disposition => 'inline'
    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.xml  { render :xml => @question_image }
    #end
  end

  # GET /question_images/new
  # GET /question_images/new.xml
  def new
    @question_image = QuestionImage.new
    @question_image.question_id = params[:id]
    
    respond_to do |format|
      format.html {render :layout => "dialog"}# new.html.erb
      format.xml  { render :xml => @question_image }
    end
  end

  # GET /question_images/1/edit
  def edit
    @question_image = QuestionImage.find(params[:id])
    render :layout => "dialog"
  end

  # POST /question_images
  # POST /question_images.xml
  def create
    @question_image = QuestionImage.new(params[:question_image])

    respond_to do |format|
      if @question_image.save
        format.html { redirect_to(:controller => "question_images", :action => "index", :notice => 'Question image was successfully created.') }
        format.xml  { render :xml => @question_image, :status => :created, :location => @question_image }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question_image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /question_images/1
  # PUT /question_images/1.xml
  def update
    @question_image = QuestionImage.find(params[:id])

    respond_to do |format|
      if @question_image.update_attributes(params[:question_image])
        format.html { redirect_to(:controller => "question_images", :action => "index", :notice => 'Question image was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question_image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /question_images/1
  # DELETE /question_images/1.xml
  def destroy
    @question_image = QuestionImage.find(params[:id])
    question_id = @question_image.question_id
    @question_image.destroy
    question = Question.find(question_id)
    respond_to do |format|
      format.html { redirect_to(edit_question_path(question), :notice => 'Image was successfully deleted.') }
      format.xml  { head :ok }
    end
  end
end
