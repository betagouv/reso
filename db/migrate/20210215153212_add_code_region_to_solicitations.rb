class AddCodeRegionToSolicitations < ActiveRecord::Migration[6.0]
  def change
    add_column :solicitations, :code_region, :integer
    add_index :solicitations, :code_region
    # Tache `rake update_solicitations_code_region` a lancer ensuite
    # (tache très longue lancee a part pour ne pas bloquer la migration)
  end
end
