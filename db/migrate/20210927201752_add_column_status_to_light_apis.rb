class AddColumnStatusToLightApis < ActiveRecord::Migration[6.0]
  def change
  	add_column :light_apis, :status, :integer, default: 0
  end
end
