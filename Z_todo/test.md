# 🧪 Guide des Tests - MAST2 Demo

## 📋 Introduction aux Tests

Les tests sont essentiels pour garantir la qualité et la fiabilité de votre application Rails. Ce guide vous explique les différents types de tests et comment les mettre en œuvre.

> **⚠️ Problèmes de Tests ?**  
> Si vous rencontrez des erreurs lors de l'exécution des tests, consultez le fichier **[EXPLICATION_ERREURS_TESTS.md](./EXPLICATION_ERREURS_TESTS.md)** qui explique en détail les erreurs courantes et leurs solutions.

---

## 🎯 Types de Tests dans Rails

### 1. **Tests Unitaires (Models)**
Testent la logique métier et les validations des modèles.

### 2. **Tests Fonctionnels (Controllers)**
Testent les actions des contrôleurs et les réponses HTTP.

### 3. **Tests d'Intégration (Integration)**
Testent les interactions entre plusieurs contrôleurs.

### 4. **Tests Système (System)**
Testent l'application complète via un navigateur simulé.

---

## 🔧 Configuration

### Gemfile (déjà configuré)
```ruby
group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
```

### 🗄️ Vérifier et Gérer les Bases de Données (avec Docker)

**Important** : Ce projet utilise Docker Compose. Toutes les commandes doivent être exécutées via Docker.

#### Lister les bases de données existantes

**Via Docker Compose (méthode principale)**
```bash
# Entrer dans le conteneur PostgreSQL
docker-compose exec postgres psql -U hello
            #si docker-compose exec postgres psql -U hello                                       
            psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  database "hello" does not exist
            #run->
            docker-compose exec web rails db:create RAILS_ENV=test
            docker-compose exec web rails db:schema:load RAILS_ENV=test
# Lister toutes les bases de données
\l

# Quitter psql
\q

# Ou en une seule commande
docker-compose exec postgres psql -U hello -l
```

**Via le conteneur web Rails**
```bash
# Vérifier la configuration de la base de données
docker-compose exec web cat config/database.yml

# Vérifier la version du schéma
docker-compose exec web rails db:version
```

#### Créer les bases de données

```bash
# Créer toutes les bases de données (development, test)
docker-compose exec web rails db:create

# Créer uniquement la base de test
docker-compose exec web rails db:create RAILS_ENV=test

# Créer et migrer
docker-compose exec web rails db:create db:migrate

# Pour l'environnement de test
docker-compose exec web rails db:create db:migrate RAILS_ENV=test
```

#### Vérifier l'état des bases de données

```bash
# Vérifier la version du schéma
docker-compose exec web rails db:version

# Vérifier le statut des migrations
docker-compose exec web rails db:migrate:status

# Pour l'environnement de test
docker-compose exec web rails db:migrate:status RAILS_ENV=test
```

#### Supprimer et recréer les bases de données

```bash
# Supprimer toutes les bases
docker-compose exec web rails db:drop

# Supprimer et recréer
docker-compose exec web rails db:drop db:create db:migrate

# Pour l'environnement de test
docker-compose exec web rails db:drop db:create db:migrate RAILS_ENV=test

# Tout en une fois (drop, create, migrate, seed)
docker-compose exec web rails db:reset
```

#### Préparer la base de test

```bash
# Préparer la base de test (crée et migre)
docker-compose exec web rails db:test:prepare

# Charger le schéma dans la base de test
docker-compose exec web rails db:schema:load RAILS_ENV=test
```

#### Résoudre l'erreur "database does not exist"

Si vous avez l'erreur `We could not find your database: hello_test` :

```bash
# 1. Vérifier que les conteneurs sont démarrés
docker-compose ps

# 2. Vérifier que PostgreSQL est accessible
docker-compose exec postgres psql -U hello -l

# 3. Créer la base de données de test
docker-compose exec web rails db:create RAILS_ENV=test

# 4. Charger le schéma
docker-compose exec web rails db:schema:load RAILS_ENV=test

# 5. Ou tout en une fois
docker-compose exec web rails db:test:prepare

# 6. Vérifier que la base existe
docker-compose exec postgres psql -U hello -l | grep hello_test
```

#### Commandes utiles PostgreSQL (via Docker)

```bash
# Se connecter à une base spécifique
docker-compose exec postgres psql -U hello -d hello_test

# Lister les tables d'une base
docker-compose exec postgres psql -U hello -d hello_test -c "\dt"

# Voir la structure d'une table
docker-compose exec postgres psql -U hello -d hello_test -c "\d clients"

# Compter les enregistrements
docker-compose exec postgres psql -U hello -d hello_test -c "SELECT COUNT(*) FROM clients;"

# Voir toutes les bases de données
docker-compose exec postgres psql -U hello -c "SELECT datname FROM pg_database;"
```

### Lancer les tests (avec Docker)

```bash
# Tous les tests
docker-compose exec web rails test

# Tests d'un fichier spécifique
docker-compose exec web rails test test/models/user_test.rb

# Tests d'un contrôleur
docker-compose exec web rails test test/controllers/clients_controller_test.rb

# Tests système
docker-compose exec web rails test:system

# Avec verbose
docker-compose exec web rails test -v

# Lancer un test spécifique (par ligne)
docker-compose exec web rails test test/models/client_test.rb:15
```

### ⚙️ Configuration de l'environnement de test (Docker)

**Pas besoin de configuration supplémentaire** : L'environnement de test utilise automatiquement :
- La même image Docker que development
- Le même conteneur PostgreSQL
- Les variables d'environnement du fichier `.env`
- La configuration de `config/database.yml`

**La base de données de test (`hello_test`) est automatiquement :**
- Créée lors du premier lancement des tests
- Vidée et rechargée avant chaque suite de tests
- Isolée de la base de développement (`hello_development`)

**Aucune modification du `docker-compose.yml` n'est nécessaire** car :
- Le conteneur `web` peut exécuter des commandes dans n'importe quel environnement
- Rails gère automatiquement l'environnement via `RAILS_ENV`
- PostgreSQL accepte plusieurs bases de données sur le même serveur

---

## 📝 Tests Unitaires (Models)

### Exemple : Test du modèle User

**Fichier** : `test/models/user_test.rb`

```ruby
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Test de validation de l'email
  test "should not save user without email" do
    user = User.new(password: "password123")
    assert_not user.save, "Saved the user without an email"
  end

  # Test de validation de l'unicité de l'email
  test "should not save user with duplicate email" do
    user1 = User.create(email: "test@example.com", password: "password123")
    user2 = User.new(email: "test@example.com", password: "password456")
    assert_not user2.save, "Saved the user with duplicate email"
  end

  # Test de la méthode fullname
  test "fullname should return nom and prenom" do
    user = User.new(nom: "Dupont", prenom: "Jean", email: "jean@example.com")
    assert_equal "Dupont Jean", user.fullname
  end

  # Test de fullname avec seulement le nom
  test "fullname should return only nom when prenom is blank" do
    user = User.new(nom: "Dupont", email: "dupont@example.com")
    assert_equal "Dupont", user.fullname
  end

  # Test de fullname avec seulement le prénom
  test "fullname should return only prenom when nom is blank" do
    user = User.new(prenom: "Jean", email: "jean@example.com")
    assert_equal "Jean", user.fullname
  end

  # Test de fullname sans nom ni prénom
  test "fullname should return email when nom and prenom are blank" do
    user = User.new(email: "test@example.com")
    assert_equal "test@example.com", user.fullname
  end

  # Test de la relation avec clients
  test "should have many clients" do
    user = User.reflect_on_association(:clients)
    assert_equal :has_many, user.macro
  end

  # Test de la suppression en cascade
  test "should destroy associated clients when user is destroyed" do
    user = users(:one) # Utilise une fixture
    client_count = user.clients.count
    assert_difference('Client.count', -client_count) do
      user.destroy
    end
  end
end
```

### 🎓 Exercice : Tests du modèle Client

**À vous de jouer !** Créez le fichier `test/models/client_test.rb` et écrivez des tests pour :

1. **Validations** :
   - Tester qu'un client ne peut pas être sauvegardé sans nom
   - Tester qu'un client ne peut pas être sauvegardé sans prénom
   - Tester qu'un client ne peut pas être sauvegardé sans user_id

2. **Relations** :
   - Tester que le client appartient à un utilisateur (belongs_to)

3. **Logique métier** :
   - Tester que la date de fin est postérieure à la date de début
   - Tester le calcul de la durée du contrat (si vous ajoutez une méthode)

4. **Méthodes personnalisées** :
   - Si vous ajoutez une méthode `full_name` qui retourne "nom prénom"
   - Si vous ajoutez une méthode `active?` qui vérifie si le contrat est en cours

**Indices** :
- Utilisez `assert_not` pour tester qu'une sauvegarde échoue
- Utilisez `assert_equal` pour comparer des valeurs
- Utilisez `assert` pour tester une condition vraie
- Utilisez les fixtures pour créer des données de test

---

## 🎮 Tests Fonctionnels (Controllers)

### Exemple : Test du contrôleur Users

**Fichier** : `test/controllers/users_controller_test.rb`

```ruby
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Utilise une fixture
    sign_in @user # Si vous utilisez Devise
  end

  # Test de l'action index
  test "should get index" do
    get users_url
    assert_response :success
    assert_not_nil assigns(:users)
  end

  # Test de l'action show
  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  # Test de l'action edit
  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  # Test de l'action update
  test "should update user" do
    patch user_url(@user), params: { 
      user: { 
        nom: "Nouveau Nom",
        prenom: "Nouveau Prénom" 
      } 
    }
    assert_redirected_to user_url(@user)
    @user.reload
    assert_equal "Nouveau Nom", @user.nom
  end

  # Test de l'action update avec données invalides
  test "should not update user with invalid data" do
    patch user_url(@user), params: { 
      user: { 
        email: "" 
      } 
    }
    assert_response :unprocessable_entity
  end

  # Test de l'action destroy
  test "should destroy user" do
    other_user = users(:two)
    assert_difference('User.count', -1) do
      delete user_url(other_user)
    end
    assert_redirected_to users_url
  end

  # Test qu'on ne peut pas supprimer son propre compte
  test "should not destroy current user" do
    assert_no_difference('User.count') do
      delete user_url(@user)
    end
    assert_redirected_to users_url
  end

  # Test de redirection si non authentifié
  test "should redirect to login if not authenticated" do
    sign_out @user
    get users_url
    assert_redirected_to new_user_session_url
  end
end
```

### 🎓 Exercice : Tests du contrôleur Clients

**À vous de jouer !** Créez le fichier `test/controllers/clients_controller_test.rb` et écrivez des tests pour :

1. **Actions de lecture** :
   - Tester l'accès à la liste des clients (index)
   - Tester l'affichage d'un client (show)
   - Tester l'accès au formulaire de création (new)
   - Tester l'accès au formulaire d'édition (edit)

2. **Actions de création** :
   - Tester la création d'un client avec des données valides
   - Tester la création d'un client avec des données invalides
   - Vérifier que le compteur de clients augmente

3. **Actions de modification** :
   - Tester la modification d'un client avec des données valides
   - Tester la modification avec des données invalides
   - Vérifier que les données sont bien mises à jour

4. **Actions de suppression** :
   - Tester la suppression d'un client
   - Vérifier que le compteur diminue
   - Vérifier la redirection après suppression

5. **Autorisations** :
   - Tester qu'un utilisateur non connecté est redirigé
   - Tester qu'un utilisateur ne peut modifier que ses propres clients (si applicable)

**Indices** :
- Utilisez `setup` pour initialiser les données de test
- Utilisez `assert_response` pour vérifier les codes HTTP
- Utilisez `assert_difference` pour vérifier les changements de compteur
- Utilisez `assert_redirected_to` pour vérifier les redirections

---

## 🌐 Tests d'Intégration

### Exemple : Test du flux d'inscription et création de client

**Fichier** : `test/integration/user_client_flow_test.rb`

```ruby
require "test_helper"

class UserClientFlowTest < ActionDispatch::IntegrationTest
  test "user signs up and creates a client" do
    # Inscription
    get new_user_registration_path
    assert_response :success

    assert_difference('User.count', 1) do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    follow_redirect!
    assert_response :success

    # Création d'un client
    get new_client_path
    assert_response :success

    assert_difference('Client.count', 1) do
      post clients_path, params: {
        client: {
          nom: "Dupont",
          prenom: "Jean",
          description: "Client test",
          date_debut: Date.today,
          date_fin: Date.today + 30.days,
          user_id: User.last.id
        }
      }
    end
    follow_redirect!
    assert_response :success
    assert_select "h1", "Détails du Client"
  end

  test "user logs in and views their clients" do
    user = users(:one)
    
    # Connexion
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }
    follow_redirect!
    assert_response :success

    # Consultation des clients
    get clients_path
    assert_response :success
    assert_select "table"
  end
end
```

### 🎓 Exercice : Tests d'intégration pour Clients

**À vous de jouer !** Créez des tests d'intégration pour :

1. **Flux complet de gestion d'un client** :
   - Connexion d'un utilisateur
   - Création d'un nouveau client
   - Modification du client
   - Consultation du client
   - Suppression du client

2. **Flux de recherche et export** :
   - Accès à la liste des clients
   - Utilisation de la recherche
   - Export en CSV
   - Export en JSON

3. **Flux multi-utilisateurs** :
   - Création de deux utilisateurs
   - Chaque utilisateur crée des clients
   - Vérifier que chaque utilisateur ne voit que ses clients

---

## 🖥️ Tests Système (avec Capybara)

### Exemple : Test système pour Users

**Fichier** : `test/system/users_test.rb`

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user) # Helper pour se connecter
  end

  test "visiting the users index" do
    visit users_url
    assert_selector "h1", text: "Gestion des Utilisateurs"
    assert_selector ".card", count: User.count
  end

  test "viewing a user profile" do
    visit users_url
    click_on "Voir", match: :first
    
    assert_selector "h1", text: "Profil Utilisateur"
    assert_text @user.email
  end

  test "editing a user" do
    visit user_url(@user)
    click_on "Modifier"
    
    fill_in "Nom", with: "Nouveau Nom"
    fill_in "Prénom", with: "Nouveau Prénom"
    click_on "Mettre à jour"
    
    assert_text "Utilisateur mis à jour avec succès"
    assert_text "Nouveau Nom"
  end

  test "searching users" do
    visit users_url
    fill_in "searchInput", with: @user.email
    
    # Vérifier que le résultat est filtré
    assert_text @user.email
  end

  test "cannot delete own account from list" do
    visit users_url
    
    # Trouver sa propre carte et vérifier qu'il n'y a pas de bouton supprimer
    within("#user_#{@user.id}") do
      assert_no_button "Supprimer"
    end
  end
end
```

### 🎓 Exercice : Tests système pour Clients

**À vous de jouer !** Créez le fichier `test/system/clients_test.rb` et écrivez des tests pour :

1. **Navigation et affichage** :
   - Visiter la page d'index des clients
   - Vérifier la présence du titre
   - Vérifier la présence du tableau
   - Compter le nombre de lignes

2. **Création d'un client** :
   - Cliquer sur "Nouveau client"
   - Remplir le formulaire
   - Soumettre le formulaire
   - Vérifier le message de succès
   - Vérifier que le client apparaît dans la liste

3. **Modification d'un client** :
   - Accéder à un client existant
   - Cliquer sur "Modifier"
   - Modifier les champs
   - Sauvegarder
   - Vérifier les modifications

4. **Suppression d'un client** :
   - Accéder à la liste
   - Cliquer sur supprimer
   - Accepter la confirmation
   - Vérifier que le client a disparu

5. **Recherche et tri** :
   - Utiliser la barre de recherche
   - Vérifier le filtrage
   - Cliquer sur les en-têtes de colonnes pour trier
   - Vérifier l'ordre des résultats

6. **Export de données** :
   - Cliquer sur "Export CSV"
   - Vérifier qu'un fichier est téléchargé
   - Cliquer sur "Export JSON"
   - Vérifier le téléchargement

**Indices** :
- Utilisez `visit` pour naviguer vers une page
- Utilisez `click_on` pour cliquer sur un bouton/lien
- Utilisez `fill_in` pour remplir un champ
- Utilisez `assert_selector` pour vérifier la présence d'éléments
- Utilisez `assert_text` pour vérifier du texte
- Utilisez `within` pour limiter la portée d'une recherche

---

## 🔧 Fixtures

Les fixtures sont des données de test prédéfinies.

### Exemple : Fixture pour User

**Fichier** : `test/fixtures/users.yml`

```yaml
one:
  email: user1@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
  nom: Dupont
  prenom: Jean

two:
  email: user2@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
  nom: Martin
  prenom: Marie
```

### 🎓 Exercice : Créer des fixtures pour Client

**À vous de jouer !** Créez le fichier `test/fixtures/clients.yml` avec :

1. Au moins 3 clients différents
2. Associés à différents utilisateurs
3. Avec des dates variées (passées, présentes, futures)
4. Avec et sans description

**Structure suggérée** :
```yaml
nom_du_client:
  nom: ...
  prenom: ...
  description: ...
  date_debut: ...
  date_fin: ...
  user: one  # Référence à la fixture user
```

---

## 📊 Helpers de Test

### Créer un helper pour l'authentification

**Fichier** : `test/test_helper.rb`

```ruby
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml
  fixtures :all

  # Helper pour se connecter avec Devise
  include Devise::Test::IntegrationHelpers
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
```

---

## ✅ Bonnes Pratiques

### 1. **Nommage des tests**
```ruby
# ✅ Bon
test "should create client with valid data"

# ❌ Mauvais
test "test1"
```

### 2. **Un test = une assertion principale**
```ruby
# ✅ Bon
test "should not save client without nom" do
  client = Client.new(prenom: "Jean")
  assert_not client.save
end

# ❌ Mauvais (trop d'assertions différentes)
test "client validations" do
  client = Client.new
  assert_not client.save
  client.nom = "Dupont"
  assert_not client.save
  client.prenom = "Jean"
  assert client.save
end
```

### 3. **Utiliser setup pour éviter la répétition**
```ruby
setup do
  @user = users(:one)
  @client = clients(:one)
end

test "should show client" do
  get client_url(@client)
  assert_response :success
end
```

### 4. **Tester les cas limites**
- Données vides
- Données trop longues
- Dates invalides
- Associations manquantes

---

## 🎯 Couverture de Tests

### Installer SimpleCov (optionnel)

**Gemfile** :
```ruby
group :test do
  gem 'simplecov', require: false
end
```

**test/test_helper.rb** :
```ruby
require 'simplecov'
SimpleCov.start 'rails'
```

Après avoir lancé les tests, consultez `coverage/index.html` pour voir la couverture.

---

## 📝 Checklist des Tests à Écrire

### Pour le modèle Client
- [ ] Validation du nom
- [ ] Validation du prénom
- [ ] Validation de user_id
- [ ] Validation des dates
- [ ] Relation belongs_to :user
- [ ] Méthode fullname (si elle existe)
- [ ] Méthode active? (si elle existe)

### Pour le contrôleur Clients
- [ ] GET index (liste)
- [ ] GET show (affichage)
- [ ] GET new (formulaire)
- [ ] GET edit (formulaire)
- [ ] POST create (avec données valides)
- [ ] POST create (avec données invalides)
- [ ] PATCH update (avec données valides)
- [ ] PATCH update (avec données invalides)
- [ ] DELETE destroy
- [ ] Redirection si non authentifié

### Tests système pour Clients
- [ ] Affichage de la liste
- [ ] Création complète via interface
- [ ] Modification via interface
- [ ] Suppression avec confirmation
- [ ] Recherche en temps réel
- [ ] Tri des colonnes
- [ ] Export CSV
- [ ] Export JSON

---

## 🚀 Commandes Utiles

```bash
# Lancer tous les tests
rails test

# Lancer les tests d'un fichier
rails test test/models/client_test.rb

# Lancer un test spécifique
rails test test/models/client_test.rb:10

# Lancer les tests système
rails test:system

# Lancer avec verbose
rails test -v

# Lancer avec backtrace complet
rails test -b

# Lancer en parallèle (plus rapide)
rails test -j 4
```

---

## 💡 Conseils

1. **Écrivez les tests AVANT le code** (TDD - Test Driven Development)
2. **Testez les cas normaux ET les cas d'erreur**
3. **Gardez vos tests simples et lisibles**
4. **Utilisez des fixtures pour les données récurrentes**
5. **Lancez les tests régulièrement**
6. **Visez une couverture de 80% minimum**
7. **Ne testez pas le framework Rails, testez VOTRE code**

---

## 🎓 Ressources

- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [RSpec Rails](https://github.com/rspec/rspec-rails) (alternative à Minitest)

---

**Bon courage pour vos tests ! 🧪**
