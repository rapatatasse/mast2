# 📖 Guide d'Utilisation - MAST2 Demo

## 🚀 Démarrage Rapide

### Lancer l'application

```bash
# Avec Docker
docker-compose up

# En local
rails s
```

Accédez à l'application : **http://localhost:8000** (Docker) ou **http://localhost:3000** (local)

---

## 🏠 Page d'Accueil

### Fonctionnalités
- **Statistiques en temps réel** : Nombre de clients, utilisateurs, total
- **Actions rapides** : Créer un client, voir tous les clients
- **Informations techniques** : Versions Ruby, Rails, technologies utilisées
- **Description du projet** : Objectifs pédagogiques

### Navigation
- Cliquez sur les cartes de statistiques pour accéder aux sections
- Utilisez les boutons d'action rapide pour créer ou consulter

---

## 👥 Gestion des Clients

### Liste des Clients (`/clients`)

#### Recherche
1. Utilisez la barre de recherche en haut
2. Tapez n'importe quel terme (nom, prénom, description)
3. Les résultats se filtrent en temps réel

#### Tri des Colonnes
1. Cliquez sur n'importe quel en-tête de colonne
2. Premier clic : tri ascendant
3. Deuxième clic : tri descendant
4. Fonctionne sur toutes les colonnes (ID, Nom, Prénom, Dates)

#### Export de Données
- **Export CSV** : Télécharge un fichier CSV avec tous les clients visibles
- **Export JSON** : Télécharge un fichier JSON avec les données structurées
- Les exports respectent les filtres de recherche actifs

#### Actions sur les Clients
- **👁️ Voir** : Affiche les détails complets du client
- **✏️ Modifier** : Ouvre le formulaire d'édition
- **🗑️ Supprimer** : Supprime le client (avec confirmation)

### Créer un Client (`/clients/new`)

1. Cliquez sur "Nouveau client" (bouton bleu)
2. Remplissez le formulaire :
   - **Nom** : Nom du client (requis)
   - **Prénom** : Prénom du client (requis)
   - **Description** : Description détaillée (optionnel)
   - **Date début** : Date de début du contrat
   - **Date fin** : Date de fin du contrat
   - **Utilisateur responsable** : Sélectionnez dans la liste
3. Cliquez sur "Créer le client"

### Voir un Client (`/clients/:id`)

#### Informations Affichées
- Nom et prénom
- Description complète
- Dates de début et fin (avec badges colorés)
- Utilisateur responsable
- Date de création

#### Calcul Automatique
- **Durée totale** : Nombre de jours entre début et fin
- **Jours restants** : Calcul automatique
- **Alerte** : Badge rouge si moins de 7 jours restants

#### Actions Disponibles
- **Retour** : Retour à la liste
- **Modifier** : Éditer le client
- **Supprimer** : Supprimer le client

### Modifier un Client (`/clients/:id/edit`)

1. Cliquez sur le bouton "Modifier" (jaune)
2. Modifiez les champs souhaités
3. Cliquez sur "Mettre à jour"
4. Vous pouvez aussi cliquer sur "Voir" pour consulter ou "Retour" pour annuler

---

## 👤 Gestion des Utilisateurs

### Liste des Utilisateurs (`/users`)

#### Affichage
- Grille de cartes avec informations clés
- Icône utilisateur avec couleur de fond
- Email, nom et prénom (si renseignés)
- Nombre de clients gérés
- Date d'inscription

#### Actions
- **👁️ Voir** : Profil détaillé de l'utilisateur
- **✏️ Modifier** : Éditer les informations
- **🗑️ Supprimer** : Supprimer l'utilisateur (sauf soi-même)

### Profil Utilisateur (`/users/:id`)

#### Sections
1. **Informations Personnelles**
   - Email
   - ID utilisateur
   - Nom et prénom
   - Dates de création et mise à jour

2. **Statistiques**
   - Nombre de clients gérés
   - Lien vers la liste des clients

3. **Liste des Clients**
   - Tableau avec tous les clients de cet utilisateur
   - Actions rapides (voir, modifier)

#### Indicateur
- Badge "C'est vous !" si vous consultez votre propre profil

### Modifier un Utilisateur (`/users/:id/edit`)

1. Cliquez sur "Modifier" (bouton jaune)
2. Modifiez :
   - Email
   - Nom
   - Prénom
3. Cliquez sur "Mettre à jour"

---

## 🔐 Authentification

### Connexion (`/users/sign_in`)

1. Entrez votre email
2. Entrez votre mot de passe
3. Cochez "Se souvenir de moi" (optionnel)
4. Cliquez sur "Se connecter"

### Inscription (`/users/sign_up`)

1. Entrez votre email
2. Choisissez un mot de passe (minimum 6 caractères)
3. Confirmez le mot de passe
4. Cliquez sur "S'inscrire"

### Mon Profil (`/users/edit`)

#### Modifier l'Email
1. Entrez le nouvel email
2. Entrez votre mot de passe actuel
3. Cliquez sur "Mettre à jour"

#### Changer le Mot de Passe
1. Entrez le nouveau mot de passe
2. Confirmez le nouveau mot de passe
3. Entrez votre mot de passe actuel
4. Cliquez sur "Mettre à jour"

#### Supprimer le Compte
1. Descendez jusqu'à la "Zone dangereuse"
2. Cliquez sur "Supprimer mon compte"
3. Confirmez l'action (irréversible)

---

## 🎨 Interface Utilisateur

### Navigation Principale

#### Menu
- **🏠 Accueil** : Page d'accueil avec statistiques
- **👥 Clients** : Gestion des clients
- **⚙️ Utilisateurs** : Gestion des utilisateurs

#### Menu Utilisateur (Dropdown)
- **👤 Mon profil** : Éditer vos informations
- **🚪 Déconnexion** : Se déconnecter

### Alertes et Notifications

#### Types d'Alertes
- **✅ Succès** (vert) : Action réussie
- **⚠️ Avertissement** (jaune) : Attention requise
- **❌ Erreur** (rouge) : Problème rencontré
- **ℹ️ Information** (bleu) : Information générale

#### Fermeture
- Cliquez sur le "×" pour fermer une alerte
- Les alertes disparaissent automatiquement après quelques secondes

### Badges de Statut

#### Couleurs
- **🟢 Vert** : Date de début, statut actif
- **🔴 Rouge** : Date de fin, alerte
- **🔵 Bleu** : Information, statistique
- **🟡 Jaune** : Avertissement
- **⚫ Gris** : Inactif, terminé

---

## 💡 Astuces et Raccourcis

### Recherche Rapide
- La recherche fonctionne sur tous les champs visibles
- Pas besoin d'appuyer sur Entrée
- Sensible à la casse (majuscules/minuscules)

### Tri des Tableaux
- Cliquez plusieurs fois pour inverser l'ordre
- Le tri fonctionne sur les nombres et le texte
- Les dates sont triées chronologiquement

### Navigation
- Utilisez les boutons "Retour" pour revenir en arrière
- Les liens actifs sont mis en surbrillance dans le menu
- Le fil d'Ariane vous aide à vous situer

### Formulaires
- Les champs requis sont marqués d'un astérisque (*)
- Les erreurs s'affichent en rouge sous les champs
- Les hints (indices) sont en gris sous les champs

---

## 🔍 Fonctionnalités Avancées

### Calcul Automatique des Durées
- La durée du contrat est calculée automatiquement
- Les jours restants sont mis à jour en temps réel
- Alerte automatique si fin proche (< 7 jours)

### Export de Données
- **CSV** : Compatible Excel, LibreOffice
- **JSON** : Pour intégration avec d'autres systèmes
- Les exports incluent uniquement les données visibles (après filtrage)

### Validation des Formulaires
- Validation côté client (HTML5)
- Validation côté serveur (Rails)
- Messages d'erreur clairs et précis

---

## 📱 Utilisation Mobile

### Responsive Design
- L'application s'adapte à tous les écrans
- Menu hamburger sur mobile
- Cartes empilées verticalement
- Tableaux avec scroll horizontal si nécessaire

### Gestes
- Swipe pour fermer les alertes
- Tap pour ouvrir les dropdowns
- Scroll pour naviguer dans les longs tableaux

---

## ⚠️ Points d'Attention

### Suppression de Données
- **Clients** : Suppression définitive (avec confirmation)
- **Utilisateurs** : Supprime aussi tous ses clients
- **Compte personnel** : Impossible de supprimer son propre compte via la liste

### Sécurité
- Déconnexion automatique après inactivité
- Mots de passe chiffrés
- Protection CSRF active
- Validation des données côté serveur

### Performance
- Les tableaux sont limités à 1000 lignes
- La recherche est instantanée
- Le tri est optimisé pour de grandes listes

---

## 🆘 Résolution de Problèmes

### Je ne peux pas me connecter
1. Vérifiez votre email et mot de passe
2. Utilisez "Mot de passe oublié ?" si nécessaire
3. Vérifiez que votre compte est actif

### Les données ne s'affichent pas
1. Actualisez la page (F5)
2. Vérifiez que vous êtes connecté
3. Vérifiez les filtres de recherche

### L'export ne fonctionne pas
1. Vérifiez que vous avez des données visibles
2. Essayez un autre format (CSV ou JSON)
3. Vérifiez les autorisations de téléchargement

### Le tri ne fonctionne pas
1. Cliquez directement sur l'en-tête de colonne
2. Attendez que l'icône change
3. Actualisez la page si nécessaire

---

## 📞 Support

Pour toute question ou problème :
1. Consultez la documentation du projet
2. Vérifiez les logs de l'application
3. Contactez l'administrateur système

---

## 🎓 Ressources Pédagogiques

### Concepts Illustrés
- **MVC** : Séparation des responsabilités
- **CRUD** : Opérations de base sur les données
- **Relations** : has_many, belongs_to
- **Authentification** : Devise
- **Responsive Design** : Bootstrap 5
- **JavaScript** : Interactivité client

### Exercices Suggérés
1. Créer 10 clients avec des données variées
2. Tester tous les filtres et tris
3. Exporter les données en CSV et JSON
4. Modifier un utilisateur et observer les changements
5. Tester l'alerte de fin de contrat proche

---

**Bon apprentissage ! 🚀**
