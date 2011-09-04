class CreateInputTypes < ActiveRecord::Migration
  def self.up
    create_table :input_types do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :input_types
  end
end
