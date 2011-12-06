class SubjectsController < ApplicationController
  
  def close_dialog
    #controller simply closes dialog see view for details
  end
  # GET /subjects
  # GET /subjects.json
  def index
    @subjects = Subject.where(:is_anonymous => :false)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    @subject = Subject.find(params[:id])

    respond_to do |format|
      format.html { render :layout => "dialog" }# show.html.erb
      format.json { render :json => @subject }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.json
  def new
    @subject = Subject.new

    respond_to do |format|
      format.html { render :layout => "dialog" }# new.html.erb
      format.json { render :json => @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = Subject.find(params[:id])
    render :layout => "dialog"
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = Subject.new(params[:subject])
    @subject.password = Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}"))[0..7]
    if @subject.identifier == nil || @subject.identifier == ""
      @subject.identifier = Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}"))[0..7]
    end
    @subject.is_anonymous = false

    respond_to do |format|
      if @subject.save
        format.html { redirect_to @subject, :notice => 'Subject was successfully created.' }
        format.json { render :json => @subject, :status => :created, :location => @subject }
      else
        format.html { render :action => "new", :layout => "dialog" }
        format.json { render :json => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.json
  def update
    @subject = Subject.find(params[:id])

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        format.html { redirect_to(close_dialog_statistician_path(@subject))}
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject = Subject.find(params[:id])
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to subjects_url }
      format.json { head :ok }
    end
  end
end
