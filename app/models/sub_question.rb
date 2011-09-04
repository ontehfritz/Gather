class SubQuestion < ActiveRecord::Base
  belongs_to :question_parent, :class_name => :Question
  belongs_to :question_sub, :class_name => :Question
end
