NAME=inception
DATA_PATH=/home/$(USER)/data
COMPOSE_FILE=./srcs/docker-compose.yml


all: build

setup:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

build: setup
	@docker compose -f $(COMPOSE_FILE) up -d --build

up:
	@docker compose -f $(COMPOSE_FILE) up -d
start:
	@docker compose -f $(COMPOSE_FILE) start
down:
	@docker compose -f $(COMPOSE_FILE) down

restart:
	@docker compose -f $(COMPOSE_FILE) restart

clean: down
	@docker system prune -af

fclean:clean
	@docker volume rm $$(docker image ls -q) 2>/dev/null || true
	@rm -rf $(DATA_PATH)

re: clean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

status:
	@docker compose -f $(COMPOSE_FILE) ps
