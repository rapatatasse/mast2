json.extract! client, :id, :nom, :prenom, :description, :date_debut, :date_fin, :created_at, :updated_at
json.url client_url(client, format: :json)
