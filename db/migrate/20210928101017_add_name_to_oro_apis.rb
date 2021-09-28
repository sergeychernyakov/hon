class AddNameToOroApis < ActiveRecord::Migration[6.0]
  def change
  	add_column :oro_apis, :name, :string
  end
end
