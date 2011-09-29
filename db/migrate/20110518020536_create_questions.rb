class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.text :question_text
      t.string :instructions, :limit => 512
      t.integer :sort_index
      t.string :short_name
      t.string :additional_comments, :limit => 512
      t.text :matrix_columns
      t.integer :rating
      t.boolean :is_hidden
      t.boolean :has_sub_question
      t.boolean :is_answer_required
      t.boolean :is_sub
      t.boolean :active
      t.string :type
      t.references :section
      t.references :option
      t.references :input_type
      t.references :question_type

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
