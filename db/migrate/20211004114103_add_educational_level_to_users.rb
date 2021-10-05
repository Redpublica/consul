class AddEducationalLevelToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :educational_level, :string
  end
end
