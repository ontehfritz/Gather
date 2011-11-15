class Question < ActiveRecord::Base
  validates :question_text, :presence => true 
  
  # def types  
    # self.type 
  # end 
  # def types=(type)   
    # self.type = type
  # end
  
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Question.model_name
      end
    end
    super
  end
  
  belongs_to :section
  belongs_to :option
  belongs_to :input_type
  belongs_to :question_type
  has_one :question_image
  has_many :skip_logics
  has_many :responses,:dependent => :destroy
  has_many :elements,:dependent => :destroy
  has_many(:sub_questions, :foreign_key => :question_parent_id, :dependent => :destroy)
  #has_many(:reverse_sub_questions, :class_name => :SubQuestion,
  #    :foreign_key => :question_sub_id, :dependent => :destroy)
  has_many :questions, :through => :sub_questions, :source => :question_sub, :dependent => :destroy
  #accepts_nested_attributes_for :elements, :reject_if => lambda { |a| a[:element_text].blank? }, :allow_destroy => true
end
