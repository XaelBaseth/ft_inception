# Variables -------------------------------------------------------------------

NAME		= inception
COMPOSE		= ./srcs/docker-compose.yml
HOST_URL	= acharlot.42.fr

# Rules -----------------------------------------------------------------------

all: $(NAME)

$(NAME): up

up: create_dir
	@docker compose -f $(COMPOSE) up
	@docker compose -f $(COMPOSE) build

down:
	@docker compose -p $(COMPOSE) down

create_dir:
	@mkdir -p ~/data/database
	@mkdir -p ~/data/wordpress_files

clean:
	@docker compose -f $(COMPOSE) down -v

fclean: clean 
	@sudo rm -rf ~/data
	@docker system prune --volumes

re: fclean all

.PHONY: all up down create_dir clean fclean re