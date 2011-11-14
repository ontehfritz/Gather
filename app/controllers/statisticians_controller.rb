class StatisticiansController < ApplicationController
  before_filter :authenticate_user!, :except => [:show_logo]  
  
  
  def save_sort
    if params[:commit] == "Survey"
      redirect_to(:controller => "statisticians",:action => "edit", :id => params[:id])
      return
    end
    
    @order = params[:sort_order]
    @order.split(',').each_with_index do |section, i|
      Section.update(section, :sort_index => i+1)
    end
    statistician = Statistician.find(params[:id])
    redirect_to(statistician_sections_path(statistician))
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
        #logger.debug "CSS PATH:#{Rails.root}/public/stylesheets/statistician.css"
        #File.copy("#{Rails.root}/public/stylesheets/statistician.css", 
        #    "#{Rails.root}/public/stylesheets/statistician_#{@statistician.id.to_s}.css")
        Style.create(:statistician_id => @statistician.id, :background => "#F0F0F0", :font_color => "#696969", :question_font_color => "#000000")
        format.html { redirect_to(edit_statistician_path(@statistician), :notice => 'Statistician was successfully created.') }
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
        format.html { redirect_to(edit_statistician_path(@statistician), :notice => 'Statistician was successfully updated.') }
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
        redirect_to(:controller => "statisticians", :action => "close_dialog")
        return 
      else
        @error = true
      end
    elsif params[:commit] == "Disable"
      Statistician.update(@statistician.id, :unlock_key => nil, :is_password_required => false)
      @complete = true
      redirect_to(:controller => "statisticians", :action => "close_dialog")
      return
    elsif params[:commit] == "Cancel"
      @complete = true
      redirect_to(:controller => "statisticians", :action => "close_dialog")
      return
    end
    
    render :layout => "dialog"
  end
  
  def new_logo
    @statistician = Statistician.find(params[:id])
    
    respond_to do |format|
      format.html {render :layout => "dialog"}# new.html.erb
      format.xml  { render :xml => @statistician }
    end
  end
  
  def create_logo
    @statistician = Statistician.find(params[:id])

    respond_to do |format|
      if @statistician.update_attributes(params[:statistician])
        format.html { redirect_to(close_dialog_statistician_path(@statistician)) }
        format.xml  { render :xml => @statistician, :status => :created, :location => @statistician}
      else
        format.html { render :action => "new_logo" }
        format.xml  { render :xml => @statistician.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show_logo
    @statistician = Statistician.find(params[:id])

    @image = @statistician.image_data
    send_data @image, :type => @statistician.content_type, 
        :filename => @statistician.file_name, :disposition => 'inline'
  end
  
  def edit_logo
    @statistician = Statistician.find(params[:id])
    render :layout => "dialog"
  end
  
  def update_logo
    @statistician = Statistician.find(params[:id])

    respond_to do |format|
      if @statistician.update_attributes(params[:statistician])
        format.html { redirect_to(close_dialog_statistician_path(@statistician)) }
        format.xml  { render :xml => @statistician, :status => :created, :location => @statistician}
      else
        format.html { render :action => "new_logo" }
        format.xml  { render :xml => @statistician.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  def close_dialog
    #controller simply closes dialog see view for details
  end
end
