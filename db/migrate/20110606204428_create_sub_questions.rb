class CreateSubQuestions < ActiveRecord::Migration
  def self.up
    create_table :sub_questions do |t|
      t.integer :question_parent_id, :null => false
      t.integer :question_sub_id, :null => false
      t.integer :element_id
      t.timestamps
    end
  end

  def self.down
    drop_table :sub_questions
  end
end
