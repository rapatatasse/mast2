# `accepts_nested_attributes_for` - Guide Complet

## 🎯 À quoi ça sert ?

`accepts_nested_attributes_for` permet de **créer ou modifier des enregistrements associés en même temps que l'enregistrement parent**, via un seul formulaire.

### Exemple concret avec le projet :

**Sans `accepts_nested_attributes_for`**, pour créer un Project avec ses ClientProjects :
1. Créer le Project
2. Puis créer manuellement chaque ClientProject un par un

**Avec `accepts_nested_attributes_for`** :
- **Un seul formulaire** pour créer le Project ET assigner les clients avec leurs rôles en une seule fois

---

## 🎓 Avantages

✅ **Un seul formulaire** pour gérer parent + enfants  
✅ **Une seule requête** de sauvegarde  
✅ **Validation atomique** (tout ou rien)  
✅ **Code plus propre** dans le controller  

---

## 📋 Implémentation complète

### Étape 1 : Dans le modèle `Project`

```ruby
# app/models/project.rb
class Project < ApplicationRecord
  belongs_to :user
  has_many :client_projects, dependent: :destroy
  has_many :clients, through: :client_projects
  
  # Cette ligne magique permet de gérer les client_projects via le formulaire Project
  accepts_nested_attributes_for :client_projects, 
                                allow_destroy: true,
                                reject_if: :all_blank
end
```

**Options importantes** :
- `allow_destroy: true` → Permet de supprimer des associations via le formulaire
- `reject_if: :all_blank` → Ignore les formulaires vides
- `reject_if: proc { |attr| attr['client_id'].blank? }` → Condition personnalisée

---

### Étape 2 : Dans le modèle `ClientProject` (table de jonction)

```ruby
# app/models/client_project.rb
class ClientProject < ApplicationRecord
  belongs_to :client
  belongs_to :project
  
  # Variable globale pour les rôles
  ROLES = ['Chef de projet', 'Collaborateur', 'Observateur'].freeze
  
  validates :role, inclusion: { in: ROLES }
  validates :client_id, uniqueness: { scope: :project_id, message: "déjà assigné à ce projet" }
end
```

---

### Étape 3 : Dans le controller `ProjectsController`

```ruby
# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  
  def index
    @projects = Project.includes(:clients, :user).all
  end
  
  def show
  end
  
  def new
    @project = Project.new
    # Préparer 3 client_projects vides pour le formulaire
    3.times { @project.client_projects.build }
  end
  
  def edit
    # Ajouter des lignes vides pour pouvoir ajouter de nouveaux clients
    3.times { @project.client_projects.build }
  end
  
  def create
    @project = current_user.projects.new(project_params)
    
    if @project.save
      redirect_to @project, notice: 'Project créé avec succès'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project mis à jour avec succès'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @project.destroy
    redirect_to projects_path, notice: 'Project supprimé avec succès'
  end
  
  private
  
  def set_project
    @project = Project.find(params[:id])
  end
  
  def project_params
    params.require(:project).permit(
      :nom, 
      :description, 
      :budget, 
      :deadline,
      # Ici on autorise les nested attributes pour client_projects
      client_projects_attributes: [
        :id,           # Nécessaire pour l'update
        :client_id,    # Le client à assigner
        :role,         # Le rôle du client
        :_destroy      # Nécessaire si allow_destroy: true
      ]
    )
  end
end
```

**Points clés** :
- `client_projects_attributes` → Nom spécial (nom_association + `_attributes`)
- `:id` → Nécessaire pour identifier les enregistrements existants lors de l'update
- `:_destroy` → Permet de supprimer des associations si `allow_destroy: true`
- `3.times { @project.client_projects.build }` → Crée 3 formulaires vides

---

### Étape 4 : Dans le formulaire (vue)

```erb
<!-- app/views/projects/_form.html.erb -->
<%= simple_form_for(@project) do |f| %>
  <%= f.error_notification %>
  <%= f.error_notification message: f.object.errors[:base].to_sentence if f.object.errors[:base].present? %>

  <div class="form-inputs">
    <%= f.input :nom, label: "Nom du projet" %>
    <%= f.input :description, as: :text, input_html: { rows: 4 } %>
    <%= f.input :budget, label: "Budget (€)" %>
    <%= f.input :deadline, as: :date, html5: true, label: "Date limite" %>
    
    <hr class="my-4">
    
    <h4>Assigner des clients au projet</h4>
    <p class="text-muted">Sélectionnez les clients et leur rôle dans le projet</p>
    
    <!-- fields_for crée un sous-formulaire pour chaque client_project -->
    <%= f.simple_fields_for :client_projects do |cp| %>
      <div class="nested-fields border rounded p-3 mb-3 bg-light">
        <div class="row">
          <div class="col-md-6">
            <%= cp.input :client_id, 
                         collection: Client.order(:nom), 
                         label_method: lambda { |c| "#{c.nom} #{c.prenom}" },
                         value_method: :id,
                         include_blank: "-- Sélectionner un client --",
                         label: "Client" %>
          </div>
          
          <div class="col-md-4">
            <%= cp.input :role, 
                         collection: ClientProject::ROLES,
                         include_blank: "-- Sélectionner un rôle --",
                         label: "Rôle" %>
          </div>
          
          <div class="col-md-2 d-flex align-items-end">
            <!-- Si l'enregistrement existe déjà, afficher le bouton supprimer -->
            <% if cp.object.persisted? %>
              <%= cp.input :_destroy, 
                           as: :boolean, 
                           label: "Supprimer ?",
                           wrapper_html: { class: 'mb-0' } %>
            <% end %>
          </div>
        </div>
      </div>
    <% end %>
  </div>

  <div class="form-actions mt-4">
    <%= f.button :submit, class: "btn btn-primary" %>
    <%= link_to "Annuler", projects_path, class: "btn btn-secondary" %>
  </div>
<% end %>
```

---

### Étape 5 : Dans la vue `show` (affichage)

```html
<!-- app/views/projects/show.html.erb -->
<div class="container mt-4">
  <h1><%= @project.nom %></h1>
  
  <div class="card mb-4">
    <div class="card-body">
      <p><strong>Description :</strong> <%= @project.description %></p>
      <p><strong>Budget :</strong> <%= number_to_currency(@project.budget, unit: "€") %></p>
      <p><strong>Date limite :</strong> <%= l(@project.deadline, format: :long) if @project.deadline %></p>
      <p><strong>Créé par :</strong> <%= @project.user.email %></p>
    </div>
  </div>
  
  <h3>Clients assignés</h3>
  
  <% if @project.client_projects.any? %>
    <div class="row">
      <% @project.client_projects.each do |cp| %>
        <div class="col-md-4 mb-3">
          <div class="card">
            <div class="card-body">
              <h5 class="card-title"><%= cp.client.nom %> <%= cp.client.prenom %></h5>
              <p class="card-text">
                <span class="badge bg-primary"><%= cp.role %></span>
              </p>
              <%= link_to "Voir le client", client_path(cp.client), class: "btn btn-sm btn-outline-primary" %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
  <% else %>
    <p class="text-muted">Aucun client assigné à ce projet.</p>
  <% end %>
  
  <div class="mt-4">
    <%= link_to "Modifier", edit_project_path(@project), class: "btn btn-warning" %>
    <%= link_to "Retour", projects_path, class: "btn btn-secondary" %>
    <%= button_to "Supprimer", project_path(@project), 
                  method: :delete, 
                  data: { confirm: "Êtes-vous sûr ?" },
                  class: "btn btn-danger" %>
  </div>
</div>
```

---

## 🔄 Flux de données détaillé

### 1. Formulaire HTML généré

Quand vous utilisez `fields_for :client_projects`, Rails génère :

```html
<input name="project[nom]" value="Mon Projet">
<input name="project[budget]" value="50000">

<!-- Premier client_project -->
<select name="project[client_projects_attributes][0][client_id]">
  <option value="1">Client A</option>
  <option value="2">Client B</option>
</select>
<select name="project[client_projects_attributes][0][role]">
  <option value="Chef de projet">Chef de projet</option>
  <option value="Collaborateur">Collaborateur</option>
</select>

<!-- Deuxième client_project -->
<select name="project[client_projects_attributes][1][client_id]">
  <option value="3">Client C</option>
</select>
<select name="project[client_projects_attributes][1][role]">
  <option value="Observateur">Observateur</option>
</select>
```

---

### 2. Params reçus dans le controller

```ruby
{
  "project" => {
    "nom" => "Mon Projet",
    "description" => "Description du projet",
    "budget" => "50000",
    "deadline" => "2025-12-31",
    "client_projects_attributes" => {
      "0" => { 
        "client_id" => "1", 
        "role" => "Chef de projet" 
      },
      "1" => { 
        "client_id" => "3", 
        "role" => "Observateur" 
      }
    }
  }
}
```

---

### 3. Rails crée automatiquement

Quand vous faites `@project.save` :

1. **Crée le Project** avec nom, description, budget, deadline
2. **Crée automatiquement 2 ClientProjects** :
   - ClientProject 1 : `project_id: 1, client_id: 1, role: "Chef de projet"`
   - ClientProject 2 : `project_id: 1, client_id: 3, role: "Observateur"`

**Tout en une seule transaction !**

---

## 🔧 Cas d'usage avancés

### Ajouter dynamiquement des champs avec JavaScript (optionnel)

Si vous voulez permettre d'ajouter des clients dynamiquement sans recharger la page :

```javascript
// app/javascript/nested_forms.js
document.addEventListener('turbo:load', () => {
  const addButton = document.querySelector('#add-client-field');
  if (addButton) {
    addButton.addEventListener('click', (e) => {
      e.preventDefault();
      // Logique pour dupliquer un champ
      // (nécessite un peu plus de JavaScript)
    });
  }
});
```

---

### Validation conditionnelle

```ruby
# app/models/client_project.rb
class ClientProject < ApplicationRecord
  belongs_to :client
  belongs_to :project
  
  ROLES = ['Chef de projet', 'Collaborateur', 'Observateur'].freeze
  
  validates :role, inclusion: { in: ROLES }
  validates :client_id, uniqueness: { scope: :project_id }
  
  # Un seul chef de projet par projet
  validate :only_one_chef_de_projet
  
  private
  
  def only_one_chef_de_projet
    if role == 'Chef de projet'
      existing = project.client_projects.where(role: 'Chef de projet')
      existing = existing.where.not(id: id) if persisted?
      
      if existing.exists?
        errors.add(:role, "Il ne peut y avoir qu'un seul chef de projet")
      end
    end
  end
end
```

---

## ⚠️ Pièges à éviter

### 1. Oublier `:id` dans les params

```ruby
# ❌ MAUVAIS - Ne fonctionnera pas pour l'update
client_projects_attributes: [:client_id, :role]

# ✅ BON
client_projects_attributes: [:id, :client_id, :role, :_destroy]
```

### 2. Ne pas construire de formulaires vides

```ruby
# ❌ MAUVAIS - Aucun champ ne s'affichera
def new
  @project = Project.new
end

# ✅ BON
def new
  @project = Project.new
  3.times { @project.client_projects.build }
end
```

### 3. Problème N+1 dans l'index

```ruby
# ❌ MAUVAIS - Requête N+1 (il faut faire plusieurs requêtes pour charger les données)
@projects = Project.all

# ✅ BON - Eager loading (c'est plus rapide car il charge les données en une seule requête)
@projects = Project.includes(:clients, :client_projects, :user).all
```

---

## 🎯 Alternative sans nested attributes

Si vous ne voulez pas utiliser `accepts_nested_attributes_for` :

```ruby
# Controller
def create
  @project = Project.new(project_params)
  
  if @project.save
    # Créer manuellement les associations
    params[:client_ids].each_with_index do |client_id, index|
      @project.client_projects.create(
        client_id: client_id,
        role: params[:roles][index]
      )
    end
    redirect_to @project
  else
    render :new
  end
end
```

**C'est plus verbeux et moins élégant.**

---

## 📚 Résumé

| Aspect | Description |
|--------|-------------|
| **Modèle** | `accepts_nested_attributes_for :client_projects` |
| **Controller** | Autoriser `client_projects_attributes: [:id, :client_id, :role, :_destroy]` |
| **Vue** | Utiliser `f.simple_fields_for :client_projects` |
| **Avantage** | Un seul formulaire, une seule sauvegarde, validation atomique |
| **Cas d'usage** | Relations many-to-many avec attributs supplémentaires |

---

## 🔗 Routes nécessaires

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :projects
  resources :clients
  
  # Optionnel : routes imbriquées
  resources :clients do
    resources :projects, only: [:index, :new, :create]
  end
end
```

---

## ✅ Checklist d'implémentation

- [ ] Créer les migrations pour Project et ClientProject
- [ ] Ajouter `accepts_nested_attributes_for` dans le modèle Project
- [ ] Définir la constante `ROLES` dans ClientProject
- [ ] Modifier `project_params` dans le controller
- [ ] Ajouter `build` dans les actions `new` et `edit`
- [ ] Créer le formulaire avec `simple_fields_for`
- [ ] Afficher les associations dans la vue `show`
- [ ] Tester la création, modification et suppression
- [ ] Optimiser avec `includes` pour éviter N+1

---

## 🚀 Pour aller plus loin

- Ajouter des validations personnalisées
- Implémenter l'ajout dynamique de champs avec Stimulus
- Créer un concern `NestedAssignable` pour réutiliser la logique
- Ajouter des callbacks pour notifier les clients assignés
