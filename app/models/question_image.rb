class QuestionImage < ActiveRecord::Base
  belongs_to :question
  
  def image_file=(input_data)
    self.file_name = input_data.original_filename
    self.content_type = input_data.content_type.chomp
    self.image_data = input_data.read
  end
  
end
