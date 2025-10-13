module UsersHelper
  def user_full_name(user)
    if user.nom.present? && user.prenom.present?
      "#{user.nom} #{user.prenom}"
    elsif user.nom.present?
      user.nom
    elsif user.prenom.present?
      user.prenom
    else
      user.email
    end
  end

  def user_initials(user)
    if user.nom.present? && user.prenom.present?
      "#{user.nom[0]}#{user.prenom[0]}".upcase
    elsif user.nom.present?
      user.nom[0..1].upcase
    elsif user.prenom.present?
      user.prenom[0..1].upcase
    else
      user.email[0..1].upcase
    end
  end

  def user_badge_color(index)
    colors = ['primary', 'success', 'info', 'warning', 'danger', 'secondary']
    colors[index % colors.length]
  end
end
