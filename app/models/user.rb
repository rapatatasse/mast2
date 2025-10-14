class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :clients, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def fullname
    if nom.present? && prenom.present?
      "#{nom} #{prenom}"
    elsif nom.present?
      nom
    elsif prenom.present?
      prenom
    else
      email
    end
  end

  def display_name
    fullname
  end
end
