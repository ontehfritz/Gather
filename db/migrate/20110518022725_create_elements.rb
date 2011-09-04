class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.text :element_text
      t.integer :score
      t.integer :sort_index
      t.boolean :active
      t.references :question

      t.timestamps
    end
  end

  def self.down
    drop_table :elements
  end
end
