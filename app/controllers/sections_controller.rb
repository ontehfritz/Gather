class SectionsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @sections = Section.where("statistician_id = ?", params[:statistician_id]).order("sort_index")
    @statistician_id = params[:statistician_id]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sections }
    end
  end

  def save_sort
    if params[:commit] == "Survey"
      redirect_to(:controller => "statisticians",:action => "edit", :id => params[:statistician_id])
      return
    end
    
    @order = params[:sort_order]
    @order.split(',').each_with_index do |section, i|
      Section.update(section, :sort_index => i+1)
    end
    redirect_to(:action => "index", :statistician_id => params[:statistician_id])
  end
  
  
  def show
    @section = Section.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @section }
    end
  end

  def new
    statistician_id = params[:statistician_id]
    @section = Section.new
    @section.statistician_id = statistician_id
    
    render :layout => "dialog"
  end

  def edit
    @section = Section.find(params[:id])
    render :layout => "dialog"
  end

  def create
    if params[:commit] == "Cancel"
      redirect_to(:controller => "sections", :action => "close_dialog")
      return 
    end
    
    @section = Section.new(params[:section])

    top_section = Section.where(:statistician_id => @section.statistician_id).order("sort_index desc").first;
    
    if top_section != nil && top_section.sort_index > 0
      @section.sort_index = top_section.sort_index + 1
    else
      @section.sort_index = 1
    end
    
    respond_to do |format|
      if @section.save
        format.html { redirect_to(:action => "close_dialog", :notice => 'Section was successfully created.')}
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        format.html { render :action => "new",:layout => "dialog" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @section = Section.find(params[:id])
    
    if params[:commit] == "Cancel"
      redirect_to(:controller => "sections", :action => "close_dialog")
      return 
    end

    respond_to do |format|
      if @section.update_attributes(params[:section])
        format.html { redirect_to(:action => "close_dialog", :notice => 'Section was successfully created.')}
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @section = Section.find(params[:id])
    statistician_id = @section.statistician_id
    @section.destroy

    respond_to do |format|
      format.html {redirect_to(:action => "index", :statistician_id => statistician_id)}
      format.xml  { head :ok }
    end
  end
  
  def close_dialog
    #controller simply closes dialog see view for details
  end
end
