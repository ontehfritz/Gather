class Element < ActiveRecord::Base
  default_scope :order => "sort_index"
  validates_presence_of :element_text
  validates_numericality_of :score, :only_integer => true
  belongs_to :question
  has_many :responses,:dependent => :destroy
end
