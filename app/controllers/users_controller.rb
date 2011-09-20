class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:some_action_without_auth]
  
  def close_dialog
    #see view closes dialogs opened by jquery
  end
  
  def index 
    @users = User.find(:all)
  end
  
  def new 
    @user = User.new
    render :layout => "dialog"
  end
  
  def create
    if params[:commit] == "Cancel"
      redirect_to(:action => "close_dialog")
      return 
    end
    
    @user = User.new(params[:user])
    if @user.save
      redirect_to(:action => "close_dialog",:notice => 'User was successfully created.')
    else
       render :action => "new" , :layout => "dialog"
    end
  end
  
  def edit
    @user = User.find(params[:id])
    render :layout => "dialog"
  end
  
  def update
    if params[:commit] == "Cancel"
      redirect_to(:action => "close_dialog")
      return 
    end
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(:action => "close_dialog", :notice => 'Answer was successfully created.')}
      else
        format.html { render :action => "edit", :layout => "dialog" }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html {redirect_to(:action => "index")}
      format.xml  { head :ok }
    end
  end
end
