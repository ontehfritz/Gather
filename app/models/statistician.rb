class Statistician < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :intro
  validates_presence_of :outro
  
  def authentication_mode
    if read_attribute(:is_anonymous)
      "anonymous"
    elsif read_attribute(:is_id_required)
      "accesscode"
    else
      "notanonymous"
    end
  end
  
  def authentication_mode=(mode)
    @authentication_mode = mode
    
    if @authentication_mode == "anonymous"
      write_attribute(:is_anonymous, 1)
    else
      write_attribute(:is_anonymous, 0)
    end
    
    if @authentication_mode == "accesscode"
      write_attribute(:is_id_required, 1)
    else
      write_attribute(:is_id_required, 0)
    end
    
  end
  
  has_many :sections, :dependent => :destroy
  has_many :user_completed_surveys
end
