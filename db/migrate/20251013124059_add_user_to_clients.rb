class AddUserToClients < ActiveRecord::Migration[7.0]
  def up
    # On ajoute la colonne de manière temporairement nullable
    add_reference :clients, :user, null: true, foreign_key: true

    # On ne fait le traitement que si la table users existe et qu'il y a au moins un user
    if table_exists?(:users) && User.any?
      default_user = User.first
      Client.where(user_id: nil).update_all(user_id: default_user.id)
    end

    # Enfin, on rend la colonne obligatoire (non nulle)
    change_column_null :clients, :user_id, false
  end

  def down
    remove_reference :clients, :user, foreign_key: true
  end
end