class CreateSkipLogicTypes < ActiveRecord::Migration
  def self.up
    create_table :skip_logic_types do |t|
      t.string :skip_type
      t.timestamps
    end
    
    SkipLogicType.create :skip_type => 'Skip'
  end

  def self.down
    drop_table :skip_logic_types
  end
end
