class CreateStatisticians < ActiveRecord::Migration
  def self.up
    create_table :statisticians do |t|
      t.string :name, :limit  => 512
      t.text :intro
      t.text :outro
      t.string :content_type
      t.string :file_name
      t.binary :image_data
      t.boolean :is_anonymous
      t.boolean :is_password_required
      t.boolean :is_id_required
      t.boolean :power
      t.boolean :multi_session
      t.string :unlock_key
      t.string :slug
      t.boolean :active
      
      t.timestamps
    end
  end

  def self.down
    drop_table :statisticians
  end
end
