class Statistician < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :intro
  validates_presence_of :outro
  
  def image_file=(input_data)
    self.file_name = input_data.original_filename
    self.content_type = input_data.content_type.chomp
    self.image_data = input_data.read
  end
  
  
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
  has_many :user_completed_surveys, :dependent => :destroy
  has_one :style
end
