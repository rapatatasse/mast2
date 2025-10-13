# Plan de Formation Master - Journée Avancée Rails

## Contexte
Application de gestion avec Users (Devise), Clients et Products.
Les étudiants ont déjà vu : création de controllers, migrations basiques, ajout de références.

---

## 🎯 PARTIE 1 : TABLES DE JONCTION & RELATIONS MANY-TO-MANY (2h30)

### 1.1 Créer le modèle Project avec table de jonction (45 min)
**Objectif** : Comprendre les relations many-to-many avec table de jonction explicite

**Actions** :
- Créer le modèle `Project` (nom, description, budget, deadline)
- Créer la table de jonction `ClientProjects` pour lier Clients et Projects
- Ajouter les relations `has_many :through` dans les modèles
- Comprendre la différence entre `has_and_belongs_to_many` et `has_many :through`
-mettre une variablr global pour role [chef de projet, collaborateur, observateur]

**Commandes** :
```bash
docker-compose exec web rails generate model Project nom:string description:text budget:decimal deadline:date user:references
docker-compose exec web rails generate model ClientProject client:references project:references role:string
docker-compose exec web rails db:migrate
```

**Fichiers à modifier** :
- `app/models/project.rb` : ajouter `has_many :client_projects` et `has_many :clients, through: :client_projects`
- `app/models/client.rb` : ajouter `has_many :client_projects` et `has_many :projects, through: :client_projects`
- `app/models/client_project.rb` : ajouter validations

---

### 1.2 Controller Projects avec logique complexe (45 min)
**Objectif** : CRUD complet avec gestion de relations multiples

**Actions** :
- Générer le controller Projects (scaffold partiel)
- Implémenter l'index avec filtres (par user, par client, par statut)
- Formulaire de création avec sélection multiple de clients
- Afficher les clients associés dans la vue show

**Commandes** :
```bash
docker-compose exec web rails generate controller Projects index show new edit create update destroy
```

**Fichiers à créer/modifier** :
- `app/controllers/projects_controller.rb`
- `app/views/projects/_form.html.erb` avec `collection_check_boxes` pour les clients
- `config/routes.rb` : ajouter `resources :projects`

---

### 1.3 Gestion avancée de la table de jonction (60 min)
**Objectif** : Manipuler les données de la table de jonction (attributs supplémentaires)

**Actions** :
- Ajouter un champ `role` dans ClientProject (chef de projet, collaborateur, observateur)
- Créer un nested form pour gérer les rôles lors de l'assignation
permet de créer ou modifier des enregistrements associés en même temps que l'enregistrement parent, via un seul formulaire.

Exemple concret avec votre projet :
Sans accepts_nested_attributes_for, pour créer un Project avec ses ClientProjects :

Créer le Project
Puis créer manuellement chaque ClientProject un par un
Avec accepts_nested_attributes_for :

Un seul formulaire pour créer le Project ET assigner les clients avec leurs rôles en une seule fois
🎓 Avantages
✅ Un seul formulaire pour gérer parent + enfants
✅ Une seule requête de sauvegarde
✅ Validation atomique (tout ou rien)
✅ Code plus propre dans le controller
- Implémenter une méthode dans le controller pour accepter les nested attributes
- Afficher les rôles dans les vues

**Fichiers à modifier** :
- `app/models/project.rb` : `accepts_nested_attributes_for :client_projects`
- `app/controllers/projects_controller.rb` : modifier `project_params`
- `app/views/projects/_form.html.erb` : utiliser `fields_for :client_projects`

---

## 🎯 PARTIE 2 : SCOPES, CALLBACKS & VALIDATIONS COMPLEXES (2h)

### 2.1 Scopes avancés (40 min)
**Objectif** : Créer des requêtes réutilisables et chainables

**Actions** :
- Créer des scopes dans Client : `actifs`, `expires_bientot`, `par_user`
- Créer des scopes dans Project : `en_cours`, `termines`, `en_retard`, `par_budget`
- Utiliser les scopes dans les controllers pour filtrer
- Créer une page de dashboard avec statistiques

**Fichiers à modifier** :
- `app/models/client.rb` : ajouter 5-6 scopes différents
- `app/models/project.rb` : ajouter 5-6 scopes différents
- `app/controllers/pages_controller.rb` : créer action `dashboard`
- `app/views/pages/dashboard.html.erb` : afficher stats avec scopes

**Exemples de scopes** :
```ruby
scope :actifs, -> { where('date_fin >= ?', Date.today) }
scope :expires_bientot, -> { where('date_fin BETWEEN ? AND ?', Date.today, 7.days.from_now) }
scope :par_budget, ->(min, max) { where(budget: min..max) }
```

---

### 2.2 Callbacks et logique métier (45 min)
**Objectif** : Automatiser des actions avec les callbacks ActiveRecord

**Actions** :
- `before_validation` : normaliser les données (upcase nom, strip espaces)
- `before_save` : calculer un champ dérivé (durée du projet, statut)
- `after_create` : logger la création, initialiser des valeurs
- `after_destroy` : nettoyer les associations orphelines
- Créer une méthode `set_default_deadline` qui calcule automatiquement une deadline

**Fichiers à modifier** :
- `app/models/client.rb` : ajouter 3-4 callbacks
- `app/models/project.rb` : ajouter 3-4 callbacks
- Tester dans la console Rails

---

### 2.3 Validations personnalisées (35 min)
**Objectif** : Créer des validations métier complexes

**Actions** :
- Validation custom : `date_fin` doit être après `date_debut`
- Validation custom : un projet ne peut pas avoir un budget négatif
- Validation conditionnelle : certains champs requis selon le statut
- Validation au niveau de la base : unicité composite (nom + user_id)
- Créer une méthode de validation personnalisée

**Fichiers à modifier** :
- `app/models/client.rb` : `validate :date_fin_after_date_debut`
- `app/models/project.rb` : validations complexes
- Tester les validations dans les formulaires

**Exemple** :
```ruby
validate :date_fin_after_date_debut

private
def date_fin_after_date_debut
  return if date_fin.blank? || date_debut.blank?
  if date_fin < date_debut
    errors.add(:date_fin, "doit être après la date de début")
  end
end
```

---

## 🎯 PARTIE 3 : QUERIES COMPLEXES & OPTIMISATION (1h30)

### 3.1 Requêtes SQL avancées avec ActiveRecord (45 min)
**Objectif** : Maîtriser les requêtes complexes sans SQL brut

**Actions** :
- Utiliser `joins` pour récupérer les projets avec leurs clients
- Utiliser `includes` pour éviter le problème N+1
- Utiliser `group` et `count` pour des statistiques
- Créer une requête avec `select` personnalisé pour calculer des agrégats
- Utiliser `having` pour filtrer après groupement

**Fichiers à créer/modifier** :
- `app/controllers/pages_controller.rb` : action `statistics`
- `app/views/pages/statistics.html.erb`

**Exemples de requêtes** :
```ruby
# Nombre de projets par client
Client.joins(:projects).group('clients.id').count

# Clients avec plus de 3 projets
Client.joins(:projects).group('clients.id').having('COUNT(projects.id) > 3')

# Budget total par user
Project.group(:user_id).sum(:budget)
```

---

### 3.2 Optimisation N+1 et eager loading (25 min)
**Objectif** : Comprendre et résoudre le problème N+1

**Actions** :
- Installer et configurer la gem `bullet` (optionnel, juste montrer le concept)
- Identifier les requêtes N+1 dans l'index des projects
- Corriger avec `includes`, `eager_load`, `preload`
- Comparer les performances avec et sans eager loading

**Fichiers à modifier** :
- `app/controllers/projects_controller.rb` : `@projects = Project.includes(:clients, :user).all`
- `app/controllers/clients_controller.rb` : optimiser les requêtes

---

### 3.3 Méthodes de classe personnalisées (20 min)
**Objectif** : Créer des méthodes de classe pour encapsuler la logique

**Actions** :
- Créer `Project.budget_total` pour calculer le budget total
- Créer `Client.avec_projets_actifs` pour récupérer les clients avec projets actifs
- Créer `User.top_contributors(limit)` pour les users avec le plus de projets
- Utiliser ces méthodes dans les controllers et vues

**Fichiers à modifier** :
- `app/models/project.rb` : méthodes de classe
- `app/models/client.rb` : méthodes de classe
- `app/models/user.rb` : méthodes de classe

---

## 🎯 PARTIE 4 : CONCERNS & REFACTORING (1h)

### 4.1 Créer des Concerns pour mutualiser le code (35 min)
**Objectif** : Comprendre les Concerns et le principe DRY

**Actions** :
- Créer un concern `Trackable` pour ajouter des timestamps personnalisés
- Créer un concern `Searchable` pour ajouter une recherche full-text simple
- Créer un concern `Archivable` pour soft-delete (archivage au lieu de suppression)
- Inclure ces concerns dans les modèles appropriés

**Fichiers à créer** :
- `app/models/concerns/trackable.rb`
- `app/models/concerns/searchable.rb`
- `app/models/concerns/archivable.rb`

**Fichiers à modifier** :
- `app/models/client.rb` : `include Searchable, Archivable`
- `app/models/project.rb` : `include Searchable, Archivable`

**Exemple de Concern** :
```ruby
module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(query) {
      where("nom ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
    }
  end
end
```

---

### 4.2 Service Objects pour logique métier complexe (25 min)
**Objectif** : Extraire la logique métier des controllers

**Actions** :
- Créer un service `ProjectAssigner` pour assigner des clients à un projet
- Créer un service `ProjectStatistics` pour calculer des statistiques
- Utiliser ces services dans les controllers
- Comprendre quand utiliser un service object

**Fichiers à créer** :
- `app/services/project_assigner.rb`
- `app/services/project_statistics.rb`

**Fichiers à modifier** :
- `app/controllers/projects_controller.rb` : utiliser les services

---

## 🎯 PARTIE 5 : ROUTES AVANCÉES & NESTED RESOURCES (45 min)

### 5.1 Routes imbriquées (nested routes) (25 min)
**Objectif** : Créer des routes RESTful imbriquées

**Actions** :
- Créer des routes imbriquées : `/clients/:client_id/projects`
- Modifier le controller Projects pour gérer le contexte client
- Créer des vues pour afficher les projets d'un client spécifique
- Ajouter des liens de navigation cohérents

**Fichiers à modifier** :
- `config/routes.rb` : ajouter nested resources
- `app/controllers/projects_controller.rb` : gérer `params[:client_id]`
- `app/views/clients/show.html.erb` : lister les projets du client

**Exemple routes** :
```ruby
resources :clients do
  resources :projects, only: [:index, :new, :create]
end
resources :projects
```

---

### 5.2 Routes personnalisées et actions custom (20 min)
**Objectif** : Ajouter des actions non-CRUD

**Actions** :
- Ajouter une action `archive` pour archiver un projet (POST)
- Ajouter une action `duplicate` pour dupliquer un projet (POST)
- Ajouter une route de collection `search` pour rechercher
- Créer les vues et formulaires correspondants

**Fichiers à modifier** :
- `config/routes.rb` : ajouter routes custom
- `app/controllers/projects_controller.rb` : implémenter les actions
- Créer les vues nécessaires

**Exemple routes** :
```ruby
resources :projects do
  member do
    post :archive
    post :duplicate
  end
  collection do
    get :search
  end
end
```

---

## 🎯 PARTIE 6 : PARTIALS, HELPERS & VUES AVANCÉES (1h)

### 6.1 Partials réutilisables et locals (25 min)
**Objectif** : Créer des composants de vue réutilisables

**Actions** :
- Créer un partial `_card.html.erb` générique pour afficher des cartes
- Créer un partial `_stats_widget.html.erb` pour afficher des statistiques
- Créer un partial `_search_form.html.erb` réutilisable
- Utiliser ces partials avec des locals dans différentes vues

**Fichiers à créer** :
- `app/views/shared/_card.html.erb`
- `app/views/shared/_stats_widget.html.erb`
- `app/views/shared/_search_form.html.erb`

---

### 6.2 Helpers personnalisés (20 min)
**Objectif** : Créer des helpers pour la logique de présentation

**Actions** :
- Créer un helper `status_badge(project)` pour afficher un badge de statut coloré
- Créer un helper `format_currency(amount)` pour formater les montants
- Créer un helper `time_until_deadline(date)` pour afficher le temps restant
- Utiliser ces helpers dans les vues

**Fichiers à modifier** :
- `app/helpers/application_helper.rb` : ajouter les helpers
- Utiliser dans les vues

---

### 6.3 Layouts et content_for (15 min)
**Objectif** : Personnaliser les layouts par page

**Actions** :
- Utiliser `content_for :title` pour des titres de page dynamiques
- Utiliser `content_for :sidebar` pour ajouter du contenu dans une sidebar
- Créer un layout alternatif pour les pages de statistiques
- Comprendre `yield` et `content_for`

**Fichiers à modifier** :
- `app/views/layouts/application.html.erb` : ajouter `yield :sidebar`
- Vues individuelles : utiliser `content_for`

---

## 🎯 BONUS : ACTIONS AVANCÉES (si temps disponible)

### B.1 Polymorphic Associations (45 min)
**Objectif** : Créer un système de commentaires polymorphique

**Actions** :
- Créer un modèle `Comment` polymorphique (commentable_type, commentable_id)
- Permettre de commenter des Clients ET des Projects
- Implémenter l'affichage et la création de commentaires
- Comprendre les associations polymorphiques

**Commandes** :
```bash
docker-compose exec web rails generate model Comment content:text user:references commentable:references{polymorphic}
```

---

### B.2 Enums et State Machine simple (30 min)
**Objectif** : Gérer des états avec enum

**Actions** :
- Ajouter un enum `status` au modèle Project (draft, active, completed, archived)
- Créer des méthodes pour changer d'état avec validations
- Ajouter des scopes basés sur les enums
- Afficher le statut dans les vues avec des couleurs

**Migration** :
```bash
docker-compose exec web rails generate migration AddStatusToProjects status:integer
```

---

### B.3 Pagination personnalisée (20 min)
**Objectif** : Implémenter une pagination sans gem

**Actions** :
- Créer une pagination manuelle avec `limit` et `offset`
- Ajouter des paramètres de page dans l'URL
- Créer des liens de navigation (précédent/suivant)
- Afficher le nombre total de pages

---

### B.4 Filtres et recherche avancée (40 min)
**Objectif** : Créer un système de filtres multiples

**Actions** :
- Créer un formulaire de recherche avec plusieurs critères
- Implémenter la logique de filtrage dans le controller
- Utiliser `ransack` pattern (sans la gem) pour construire des requêtes dynamiques
- Persister les filtres dans l'URL

---

### B.5 Export CSV (25 min)
**Objectif** : Exporter des données en CSV

**Actions** :
- Ajouter une action `export` dans ProjectsController
- Générer un fichier CSV avec les données
- Ajouter un bouton de téléchargement
- Gérer le format de réponse (respond_to)

---

### B.6 Graphiques et visualisations (35 min)
**Objectif** : Afficher des graphiques avec Chart.js

**Actions** :
- Intégrer Chart.js via importmap
- Créer des données JSON pour les graphiques
- Afficher un graphique de budget par projet
- Afficher un graphique de répartition des clients

---

## 📊 RÉCAPITULATIF DES TEMPS

| Partie | Durée | Difficulté |
|--------|-------|------------|
| Partie 1 : Tables de jonction | 2h30 | ⭐⭐⭐ |
| Partie 2 : Scopes & Callbacks | 2h00 | ⭐⭐⭐ |
| Partie 3 : Queries complexes | 1h30 | ⭐⭐⭐⭐ |
| Partie 4 : Concerns & Refactoring | 1h00 | ⭐⭐⭐⭐ |
| Partie 5 : Routes avancées | 0h45 | ⭐⭐ |
| Partie 6 : Vues avancées | 1h00 | ⭐⭐ |
| **TOTAL CORE** | **8h45** | |
| Bonus B.1 : Polymorphic | 0h45 | ⭐⭐⭐⭐⭐ |
| Bonus B.2 : Enums | 0h30 | ⭐⭐ |
| Bonus B.3 : Pagination | 0h20 | ⭐⭐ |
| Bonus B.4 : Filtres avancés | 0h40 | ⭐⭐⭐ |
| Bonus B.5 : Export CSV | 0h25 | ⭐⭐ |
| Bonus B.6 : Graphiques | 0h35 | ⭐⭐⭐ |

---

## 🎓 RECOMMANDATIONS PÉDAGOGIQUES

### Pour une journée de 6h effective :
1. **Matin (3h)** : Parties 1 et 2 (tables de jonction + scopes/callbacks)
2. **Après-midi (3h)** : Parties 3 et 4 (queries + concerns) + 1 bonus au choix

### Pour une journée de 7h :
1. Parties 1, 2, 3, 4 complètes
2. 1-2 bonus selon l'intérêt des étudiants

### Pour une journée de 8h :
1. Toutes les parties core (1-6)
2. 2-3 bonus

---

## 🔑 CONCEPTS CLÉS ABORDÉS

- ✅ Relations many-to-many avec table de jonction explicite
- ✅ Nested attributes et formulaires complexes
- ✅ Scopes chainables et requêtes réutilisables
- ✅ Callbacks ActiveRecord (before/after)
- ✅ Validations personnalisées
- ✅ Optimisation N+1 avec eager loading
- ✅ Concerns et principe DRY
- ✅ Service Objects
- ✅ Routes imbriquées (nested resources)
- ✅ Partials avec locals
- ✅ Helpers personnalisés
- ✅ Associations polymorphiques (bonus)
- ✅ Enums et gestion d'états (bonus)

---

## 📝 NOTES

- Aucune gem supplémentaire requise pour les parties core
- Tous les exercices s'appuient sur la structure existante (Users, Clients, Products)
- Progression logique : du simple au complexe
- Chaque partie peut être démontrée puis pratiquée par les étudiants
- Les bonus permettent d'adapter selon le niveau et l'intérêt du groupe
