class AddVenueIdToPlayer < ActiveRecord::Migration
  def change
    change_column :players, :email, :string, :null => false
    add_column :players, :venue_id, :integer
    add_index :players, :venue_id
  end
end
