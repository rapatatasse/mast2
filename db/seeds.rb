# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Client.destroy_all

User.destroy_all


User.create!(nom: "Admin", prenom: "Admin", email: "admin@admin.com", password: "password")
User.create!(nom: "User", prenom: "User", email: "user@user.com", password: "password")
# Créer seed pour clients avec Faker
require 'faker'

20.times do
  Client.create!(
    nom: Faker::Name.last_name,
    prenom: Faker::Name.first_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    date_debut: Faker::Date.between(from: 1.year.ago, to: Date.today),
    date_fin: Faker::Date.between(from: Date.today, to: 2.years.from_now),
    user_id: User.all.sample.id
  )
end

