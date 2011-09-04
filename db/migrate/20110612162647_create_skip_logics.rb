class CreateSkipLogics < ActiveRecord::Migration
  def self.up
    create_table :skip_logics do |t|
      t.string :types
      t.references :element 
      t.references :question
      t.references :section
      t.timestamps
    end
  end

  def self.down
    drop_table :skip_logics
  end
end
