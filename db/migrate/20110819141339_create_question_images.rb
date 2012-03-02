class CreateQuestionImages < ActiveRecord::Migration
  def self.up
    create_table :question_images do |t|
      t.references :question
      t.string :content_type
      t.string :file_name
      t.binary :image_data, :limit => 10.megabyte
      t.timestamps
    end
  end

  def self.down
    drop_table :question_images
  end
end
