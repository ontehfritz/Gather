class CreateUserSkips < ActiveRecord::Migration
  def self.up
    create_table :user_skips do |t|
      t.references :subject
      t.references :question
      t.references :section
      t.references :statistician
      t.timestamps
    end
  end

  def self.down
    drop_table :user_skips
  end
end
