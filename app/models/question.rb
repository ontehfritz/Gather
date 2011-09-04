class Question < ActiveRecord::Base
  validates_presence_of :question_text
  
  def types  
    self.type 
  end 
  def types=(type)   
    self.type = type
  end
  
  belongs_to :section
  belongs_to :option
  belongs_to :input_type
  has_one :question_image
  has_many :responses,:dependent => :destroy
  has_many :elements,:dependent => :destroy
  has_many(:sub_questions, :foreign_key => :question_parent_id, :dependent => :destroy)
  #has_many(:reverse_sub_questions, :class_name => :SubQuestion,
  #    :foreign_key => :question_sub_id, :dependent => :destroy)
  has_many :questions, :through => :sub_questions, :source => :question_sub
  has_many :skip_logics,:dependent => :destroy
end
