# Guide des Routes Rails

## Routes RESTful avec `resources`

### Routes de base

```ruby
# config/routes.rb
resources :clients
```

Cette ligne génère automatiquement **7 routes** :

| Verbe HTTP | Path | Controller#Action | Usage |
|------------|------|-------------------|-------|
| GET | /clients | clients#index | Liste tous les clients |
| GET | /clients/new | clients#new | Formulaire de création |
| POST | /clients | clients#create | Créer un client |
| GET | /clients/:id | clients#show | Afficher un client |
| GET | /clients/:id/edit | clients#edit | Formulaire d'édition |
| PATCH/PUT | /clients/:id | clients#update | Mettre à jour un client |
| DELETE | /clients/:id | clients#destroy | Supprimer un client |

### Limiter les routes générées

```ruby
# Seulement certaines actions
resources :users, only: [:index, :show, :edit, :update, :destroy]

# Toutes sauf certaines
resources :products, except: [:destroy]
```

---

## Member vs Collection

### `member` - Action sur UNE ressource spécifique

Une route **member** agit sur **un seul élément** identifié par son `:id`.

**Format de l'URL** : `/clients/:id/action`

#### Dans routes.rb

```ruby
resources :clients do
  member do
    patch :archive        # Archiver un client spécifique
    post :duplicate       # Dupliquer un client spécifique
    get :statistics       # Voir les stats d'un client
  end
end

# OU syntaxe courte (une seule action)
resources :clients do
  patch :archive, on: :member
end
```

#### Routes générées

```
PATCH  /clients/:id/archive      clients#archive
POST   /clients/:id/duplicate    clients#duplicate
GET    /clients/:id/statistics   clients#statistics
```

#### Dans le contrôleur

```ruby
class ClientsController < ApplicationController
  before_action :set_client, only: [:archive, :duplicate, :statistics]
  
  def archive
    @client.update(archived: true)
    redirect_to clients_path, notice: "Client archivé"
  end
  
  def duplicate
    @new_client = @client.dup
    @new_client.save
    redirect_to @new_client, notice: "Client dupliqué"
  end
  
  def statistics
    @stats = @client.calculate_stats
  end
  
  private
  
  def set_client
    @client = Client.find(params[:id])
  end
end
```

#### Dans la vue (HTML/ERB)

```erb
<!-- index.html.erb -->
<% @clients.each do |client| %>
  <div class="card">
    <h3><%= client.nom %></h3>
    
    <!-- Lien vers member action -->
    <%= link_to "Archiver", 
                archive_client_path(client), 
                method: :patch,
                data: { confirm: "Êtes-vous sûr ?" },
                class: "btn btn-warning" %>
    
    <%= link_to "Dupliquer", 
                duplicate_client_path(client), 
                method: :post,
                class: "btn btn-info" %>
    
    <%= link_to "Statistiques", 
                statistics_client_path(client),
                class: "btn btn-secondary" %>
  </div>
<% end %>
```

---

### `collection` - Action sur TOUTE la collection

Une route **collection** agit sur **l'ensemble des ressources**, sans `:id`.

**Format de l'URL** : `/clients/action`

#### Dans routes.rb

```ruby
resources :clients do
  collection do
    get :archived         # Liste des clients archivés
    post :bulk_delete     # Supprimer plusieurs clients
    get :export           # Exporter tous les clients
    post :import          # Importer des clients
  end
end

# OU syntaxe courte
resources :clients do
  get :archived, on: :collection
end
```

#### Routes générées

```
GET   /clients/archived      clients#archived
POST  /clients/bulk_delete   clients#bulk_delete
GET   /clients/export        clients#export
POST  /clients/import        clients#import
```

#### Dans le contrôleur

```ruby
class ClientsController < ApplicationController
  
  def archived
    @clients = Client.where(archived: true)
    render :index
  end
  
  def bulk_delete
    ids = params[:client_ids]
    Client.where(id: ids).destroy_all
    redirect_to clients_path, notice: "#{ids.count} clients supprimés"
  end
  
  def export
    @clients = Client.all
    respond_to do |format|
      format.csv { send_data @clients.to_csv }
      format.pdf { render pdf: "clients" }
    end
  end
  
  def import
    file = params[:file]
    Client.import(file)
    redirect_to clients_path, notice: "Clients importés"
  end
end
```

#### Dans la vue (HTML/ERB)

```erb
<!-- index.html.erb -->

<!-- Lien vers collection action -->
<div class="actions mb-3">
  <%= link_to "Voir les archivés", 
              archived_clients_path,
              class: "btn btn-secondary" %>
  
  <%= link_to "Exporter (CSV)", 
              export_clients_path(format: :csv),
              class: "btn btn-success" %>
</div>

<!-- Formulaire pour bulk_delete -->
<%= form_with url: bulk_delete_clients_path, method: :post do |f| %>
  <% @clients.each do |client| %>
    <div class="form-check">
      <%= check_box_tag "client_ids[]", client.id, false, id: "client_#{client.id}" %>
      <%= label_tag "client_#{client.id}", client.nom %>
    </div>
  <% end %>
  
  <%= f.submit "Supprimer la sélection", 
               class: "btn btn-danger",
               data: { confirm: "Supprimer les clients sélectionnés ?" } %>
<% end %>

<!-- Formulaire pour import -->
<%= form_with url: import_clients_path, method: :post, multipart: true do |f| %>
  <%= f.file_field :file %>
  <%= f.submit "Importer", class: "btn btn-primary" %>
<% end %>
```

---

## Tableau récapitulatif : Member vs Collection

| Critère | Member | Collection |
|---------|--------|------------|
| **Agit sur** | Un seul élément | Tous les éléments |
| **URL** | `/clients/:id/action` | `/clients/action` |
| **Nécessite un ID** | ✅ Oui | ❌ Non |
| **Exemples** | archive, duplicate, publish | export, import, bulk_delete, search |
| **Helper path** | `action_client_path(@client)` | `action_clients_path` |

---

## Exemples complets

### Exemple 1 : Système d'archivage

```ruby
# routes.rb
resources :clients do
  patch :archive, on: :member
  patch :unarchive, on: :member
  get :archived, on: :collection
end
```

```ruby
# clients_controller.rb
def archive
  @client = Client.find(params[:id])
  @client.update(archived: true)
  redirect_to clients_path, notice: "Client archivé"
end

def unarchive
  @client = Client.find(params[:id])
  @client.update(archived: false)
  redirect_to clients_path, notice: "Client désarchivé"
end

def archived
  @clients = Client.where(archived: true)
end
```

```erb
<!-- index.html.erb -->
<%= link_to "Voir les archivés", archived_clients_path, class: "btn btn-secondary" %>

<% @clients.each do |client| %>
  <% if client.archived? %>
    <%= link_to "Désarchiver", unarchive_client_path(client), method: :patch %>
  <% else %>
    <%= link_to "Archiver", archive_client_path(client), method: :patch %>
  <% end %>
<% end %>
```

---

### Exemple 2 : Actions en masse avec Stimulus

```ruby
# routes.rb
resources :clients do
  collection do
    patch :bulk_update_date
  end
end
```

```ruby
# clients_controller.rb
def bulk_update_date
  client_ids = params[:client_ids]
  new_date = params[:date_fin]
  
  Client.where(id: client_ids).update_all(date_fin: new_date)
  
  redirect_to clients_path, notice: "#{client_ids.count} clients mis à jour"
end
```

```erb
<!-- index.html.erb -->
<div data-controller="checkbox">
  <%= form_with url: bulk_update_date_clients_path, method: :patch do |f| %>
    
    <!-- Case à cocher "Tout sélectionner" -->
    <input type="checkbox" 
           data-action="checkbox#toggleAll" 
           id="select-all">
    <label for="select-all">Tout sélectionner</label>
    
    <!-- Liste des clients -->
    <% @clients.each do |client| %>
      <div>
        <%= check_box_tag "client_ids[]", 
                          client.id, 
                          false, 
                          data: { checkbox_target: "item" } %>
        <%= label_tag "client_#{client.id}", client.nom %>
      </div>
    <% end %>
    
    <!-- Champ de date -->
    <%= f.date_field :date_fin, class: "form-control" %>
    
    <!-- Bouton de soumission -->
    <%= f.submit "Mettre à jour la date de fin", class: "btn btn-primary" %>
  <% end %>
</div>
```

---

## Routes personnalisées (hors resources)

### Route simple

```ruby
# routes.rb
get '/about', to: 'pages#about'
post '/contact', to: 'pages#contact'

# Avec nom personnalisé
get '/mon-profil', to: 'users#profile', as: :my_profile
# Helper généré : my_profile_path
```

### Route avec paramètres

```ruby
get '/users/:id/profile', to: 'users#profile'
# Accès dans le contrôleur : params[:id]
```

---

## Page d'accueil différente selon authentification

### Méthode 1 : Condition dans la vue

```ruby
# routes.rb
root to: "pages#home"
```

```ruby
# pages_controller.rb
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  
  def home
    # Pas de logique, tout dans la vue
  end
end
```

```erb
<!-- app/views/pages/home.html.erb -->
<% if user_signed_in? %>
  <!-- Page pour utilisateur connecté -->
  <div class="dashboard">
    <h1>Bienvenue <%= current_user.nom %></h1>
    <%= link_to "Mes clients", clients_path, class: "btn btn-primary" %>
    <%= link_to "Mon profil", edit_user_registration_path, class: "btn btn-secondary" %>
  </div>
<% else %>
  <!-- Page pour visiteur non connecté -->
  <div class="landing">
    <h1>Bienvenue sur notre application</h1>
    <p>Gérez vos clients facilement</p>
    <%= link_to "Se connecter", new_user_session_path, class: "btn btn-primary" %>
    <%= link_to "S'inscrire", new_user_registration_path, class: "btn btn-success" %>
  </div>
<% end %>
```

---

### Méthode 2 : Vues séparées (Recommandé)

```ruby
# routes.rb
root to: "pages#home"

# Route pour le dashboard (utilisateur connecté)
get '/dashboard', to: 'pages#dashboard', as: :dashboard
```

```ruby
# pages_controller.rb
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  
  def home
    # Redirige si connecté
    redirect_to dashboard_path if user_signed_in?
  end
  
  def dashboard
    # Nécessite authentification (définie dans ApplicationController)
    @clients = current_user.clients
  end
end
```

```erb
<!-- app/views/pages/home.html.erb (visiteurs) -->
<div class="landing">
  <h1>Bienvenue</h1>
  <%= link_to "Se connecter", new_user_session_path %>
  <%= link_to "S'inscrire", new_user_registration_path %>
</div>
```

```erb
<!-- app/views/pages/dashboard.html.erb (connectés) -->
<div class="dashboard">
  <h1>Tableau de bord</h1>
  <h2>Mes clients (<%= @clients.count %>)</h2>
  <%= link_to "Voir tous mes clients", clients_path %>
</div>
```

---

### Méthode 3 : Redirection automatique dans ApplicationController

```ruby
# application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  
  def after_sign_in_path_for(resource)
    dashboard_path  # Redirige vers le dashboard après connexion
  end
end
```

```ruby
# routes.rb
# Visiteurs non connectés
root to: "pages#home"

# Utilisateurs connectés
authenticated :user do
  root to: "pages#dashboard", as: :authenticated_root
end
```

Avec cette configuration :
- Visiteur non connecté → `pages#home`
- Utilisateur connecté → `pages#dashboard`

---

## Vérifier les routes disponibles

### En ligne de commande

```bash
# Toutes les routes
rails routes

# Routes pour un contrôleur spécifique
rails routes -c clients

# Rechercher une route
rails routes | grep archive

# Format détaillé
rails routes --expanded
```

### Exemple de sortie

```
Prefix Verb   URI Pattern                  Controller#Action
clients GET    /clients(.:format)          clients#index
        POST   /clients(.:format)          clients#create
new_client GET    /clients/new(.:format)      clients#new
edit_client GET    /clients/:id/edit(.:format) clients#edit
client GET    /clients/:id(.:format)      clients#show
       PATCH  /clients/:id(.:format)      clients#update
       DELETE /clients/:id(.:format)      clients#destroy
archive_client PATCH  /clients/:id/archive(.:format) clients#archive
archived_clients GET    /clients/archived(.:format) clients#archived
```

---

## Helpers de routes

Rails génère automatiquement des helpers pour chaque route :

```ruby
# Routes resources
clients_path          # /clients
client_path(@client)  # /clients/1
new_client_path       # /clients/new
edit_client_path(@client)  # /clients/1/edit

# Routes member
archive_client_path(@client)  # /clients/1/archive

# Routes collection
archived_clients_path  # /clients/archived

# Avec paramètres
client_path(@client, format: :pdf)  # /clients/1.pdf
clients_path(page: 2)               # /clients?page=2
```

### Dans les vues

```erb
<!-- Liens -->
<%= link_to "Liste", clients_path %>
<%= link_to "Voir", client_path(@client) %>
<%= link_to "Éditer", edit_client_path(@client) %>

<!-- Formulaires -->
<%= form_with model: @client, url: client_path(@client), method: :patch do |f| %>
  ...
<% end %>

<!-- Redirections dans le contrôleur -->
redirect_to clients_path
redirect_to @client  # Équivalent à client_path(@client)
redirect_to [:edit, @client]  # Équivalent à edit_client_path(@client)
```

---

## Bonnes pratiques

1. **Utilisez `resources`** pour les CRUD standards
2. **Member pour un élément**, **Collection pour plusieurs**
3. **Nommez clairement** vos actions personnalisées
4. **Limitez les routes** avec `only` ou `except`
5. **Groupez les routes** liées dans le même bloc
6. **Utilisez les helpers** plutôt que d'écrire les URLs en dur
7. **Vérifiez vos routes** avec `rails routes` régulièrement

---

## Ressources

- Guide officiel : https://guides.rubyonrails.org/routing.html
- API Documentation : https://api.rubyonrails.org/classes/ActionDispatch/Routing.html
