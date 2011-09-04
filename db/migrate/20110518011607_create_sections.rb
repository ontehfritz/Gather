class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :name, :limit => 512
      t.text :description
      t.integer :sort_index
      t.boolean :active
      t.references :statistician
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
