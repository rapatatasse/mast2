class Client < ApplicationRecord
    belongs_to :user
    validates :nom, presence: true
    validates :prenom, presence: true

    #serach avvec pg_search gem sur champ et again mail user
    include PgSearch::Model
  pg_search_scope :search,
    against: [:nom, :prenom],
    associated_against: {
      user: [ :email],
    },
    using: {
      tsearch: { prefix: true },
    }

end
