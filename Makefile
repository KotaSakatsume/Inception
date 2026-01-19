NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml
WOEDPERSS_DATA = /home/kosakats/data/wordpress
MARIADB_DATA = /home/kosakats/data/mariadb

all: up

up:
	$(COMPOSE) up

build:
	mkdir -p $(WOEDPERSS_DATA)
	mkdir -p $(MARIADB_DATA)
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
