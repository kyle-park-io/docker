docker compose -f ./docker-compose.yaml up -d

docker compose -f ./docker-compose.yaml up --build redis
docker compose -f ./docker-compose.yaml build redis --no-cache

docker compose down

docker exec -it dev-redis-1 redis-cli
docker exec -it dev-redis-1 bash

docker start dev-redis-1
docker stop dev-redis-1
docker rm dev-redis-1
