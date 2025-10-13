

#### Ruby et rails avec Docker: ####
docker :
1ere lancement et lorsque changement de gems :

copier coller env.exemple -> .env

```bash
docker-compose up --build 
```

sinon :
```bash
docker-compose up
```

si besoin de nommer le conteneur :
```bash     
docker-compose -p mast2testapp up 
```

ouvrire http://localhost:8000/


action pour rails (voir docker compose) :
```bash
docker-compose exec web rails db:create
```
pour crer migration et autre action voir 
https://sites.google.com/view/tpass-bibli/g%C3%A9n%C3%A9rateur-de-code-ruby-on-rails
devant commet mettre :
```bash
docker-compose exec web rails generate migration AddNomToUsers nom:string		
```
exemple :
```bash
docker-compose exec web rails generate model Clients Username:string Lastname:string phone:string mail:string comment:string actif:boolean user:references 
```
docker-compose exec web  rails generate scaffold Clients nom:string prenom:string description:text date_debut:date date_fin:date --no-stylesheets


#### Ruby et rails en local: ####
installer ruby "3.2.2"

dans terminal :
bundle install

```bash
rails db:migrate
rails db:seed
rails s
```


## Si erreure ##
Jestion ereure serveur.pid
supprimer le fichier manuellement avec commande suivante :
```bash
rm -f tmp/pids/server.pid
```

