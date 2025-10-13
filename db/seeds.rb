# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.destroy_all
Client.destroy_all


User.create!(nom: "Admin", prenom: "Admin", email: "admin@admin.com", password: "password")
User.create!(nom: "User", prenom: "User", email: "user@user.com", password: "password")
#creer seed pour clientsboucle pour 20 clients
20.times do |i|
  Client.create!(nom: "Client #{i+1}", prenom: "Client #{i+1}", description: "Client #{i+1}", date_debut: Date.today, date_fin: Date.today + 1.year)
end

