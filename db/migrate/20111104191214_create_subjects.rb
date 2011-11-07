class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :identifier
      t.string :first_name, :limit => 512
      t.string :middle_name, :limit => 512
      t.string :last_name, :limit => 512
      t.string :email, :limit => 1026
      t.boolean :is_anonymous
      t.string :password, :limit => 1026
      
      t.timestamps
    end
  end
end
