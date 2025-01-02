Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
App qui marche a par boostrap

en local:
installer ruby "3.2.2"

dans terminal :
bundle install
yarn install
rails db:migrate
rails db:seed

rails s


docker :

docker build -t mast2 .

docker run mast2



docker-compose up --build
docker compose --profile postgres --profile web up --build
docker-compose down -v


action pour rails (voir docker compose) :
docker-compose exec web rails db:create
