class CreateQuestionTypes < ActiveRecord::Migration
  def self.up
    create_table :question_types do |t|
      t.string :type_name
      t.boolean :is_multi_answer

      t.timestamps
    end
    
    QuestionType.create :type_name => 'MultipleChoiceRadio', :is_multi_answer => false
    QuestionType.create :type_name => 'MultipleChoiceCheckbox', :is_multi_answer => true
    QuestionType.create :type_name => 'FreeForm', :is_multi_answer => false
    QuestionType.create :type_name => 'Scale', :is_multi_answer => true
    QuestionType.create :type_name => 'Likert', :is_multi_answer => true
    
  end

  def self.down
    drop_table :question_types
  end
end
