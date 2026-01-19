NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	$(COMPOSE) up

build:
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

re:
	$(COMPOSE) down
	$(COMPOSE) up --build

clean:
	$(COMPOSE) down -v

fclean:
	$(COMPOSE) down -v --remove-orphans
	docker system prune -af

logs:
	$(COMPOSE) logs

ps:
	$(COMPOSE) ps

.PHONY: all up down re clean fclean logs ps
