class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.string :name

      t.timestamps
    end
    Option.create :name => 'None'
    Option.create :name => 'Last answer is other'
    Option.create :name => 'Additional Comments'
  end

  def self.down
    drop_table :options
  end
end
