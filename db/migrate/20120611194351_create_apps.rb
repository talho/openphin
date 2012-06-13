class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string  :name
      t.string  :domain
      t.string  :aliases
      t.integer :public_role_id
      t.integer :root_jurisdiction_id
      t.string  :logo_file_name
      t.string  :tiny_logo_file_name
      t.string  :about_label
      t.text    :about_text
      t.string  :help_email
      t.timestamps
    end
  end
end
