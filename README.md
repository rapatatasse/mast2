
```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```



Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

#### Ruby et rails avec Docker: ####
docker :
1ere lancement et lorsque changement de gems :

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

