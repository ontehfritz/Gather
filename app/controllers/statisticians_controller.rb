require 'ftools'
class StatisticiansController < ApplicationController
  before_filter :authenticate_user!
  
  
  def save_sort
    if params[:commit] == "Survey"
      redirect_to(:controller => "statisticians",:action => "edit", :id => params[:id])
      return
    end
    
    @order = params[:sort_order]
    @order.split(',').each_with_index do |section, i|
      Section.update(section, :sort_index => i+1)
    end
    redirect_to(:action => "index", :statistician_id => params[:id])
  end
  
  def index
   redirect_to(:controller => "workbench", :action => "index",:id => nil)
  end

  def new
    @statistician = Statistician.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @statistician }
    end
  end

  def edit
    @statistician = Statistician.find(params[:id])
  end

  def create
    if params[:commit] == "Cancel"
      redirect_to(:controller=>"workbench", :action => "index", :id => nil)
      return
    end
    @statistician = Statistician.new(params[:statistician])
    @statistician.is_anonymous = true
    
    respond_to do |format|
      if @statistician.save
        logger.debug "CSS PATH:#{Rails.root}/public/stylesheets/statistician.css"
        File.copy("#{Rails.root}/public/stylesheets/statistician.css", 
            "#{Rails.root}/public/stylesheets/statistician_#{@statistician.id.to_s}.css")
        format.html { redirect_to(:action => "edit", :id => @statistician.id, :notice => 'Statistician was successfully updated.') }
        format.xml  { render :xml => @statistician, :status => :created, :location => @statistician }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @statistician.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    if params[:commit] == "Cancel"
      redirect_to(:controller=>"workbench", :action => "index", :id => nil)
      return
    end
    
    @statistician = Statistician.find(params[:id])

    respond_to do |format|
      if @statistician.update_attributes(params[:statistician])
        format.html { redirect_to(:action => "edit", :notice => 'Statistician was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @statistician.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @statistician = Statistician.find(params[:id])
    @statistician.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => "workbench", :action => "index",:id => nil) }
      format.xml  { head :ok }
    end
  end
  
  def password
    @complete = false 
    @error = false
    @statistician = Statistician.find(params[:id])
    
    if params[:commit] == "Continue"
      if (params[:password] != nil && params[:password] != "") && (params[:password] == params[:confirm_password])
        @complete = true
        Statistician.update(@statistician.id, :unlock_key => params[:password], :is_password_required => true)
      else
        @error = true
      end
    elsif params[:commit] == "Disable"
      Statistician.update(@statistician.id, :unlock_key => nil, :is_password_required => false)
      @complete = true
    elsif params[:commit] == "Cancel"
      @complete = true
    end
    
    render :layout => "dialog"
  end
end
