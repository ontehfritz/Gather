class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string :background
      t.string :question_font_color
      t.string :font_color
      
      t.references :statistician
      t.timestamps
    end
  end
end
