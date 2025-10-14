class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :nom
      t.string :prenom
      t.text :description
      t.date :date_debut
      t.date :date_fin

      t.timestamps
    end
  end
end
