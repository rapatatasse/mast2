Travail avec ses ficheirs : 
db\schema.rb   -> ficheir pour voir la structure de votre db (ne pas modifier ce fichier) avvec au michier de migration et aux seeds
app\views\pages -> vos view
config\routes.rb -> les routes
app\controllers -> les controlleurs
app\models -> les models
app\assets\stylesheets -> votre style


bibli : https://sites.google.com/view/tpass-bibli/g%C3%A9n%C3%A9rateur-de-code-ruby-on-rails
(aide pour les migrations)

### Faire action sur vue
Sur client si pas de date mettre bouton pour rajouter date automatiquement (pas de nouvelle route)
Sur client mettre une search bar pour chercher un client avec pg_search sur email nom et prenom et user.email

### Lancer les test sur Clients_contoller 
lire test.md pour comprendre la logique des tests
resoudres les erreures sur les tests
creer test sur User sur le controller


### Bouton à cocher sur Client
rajouter des case a cocher sur client et bouton action pour mettre a jours la date de fin en fonction des client cocher faire ceci avec stimulus.
Nécessite une nouvelle fonction dans le controller donc une nouvelle route 



### Lire le fichier nested 
creer les controlleur et vues demandées et créer le formulaire imbriqué.


### creer vue pdf avec wicked_pdf
