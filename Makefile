# ==============================================================================
# Liprerie - Root Infrastructure Makefile
# Developed by: HoodieYlya13, Akaby, & Algebrino
# ==============================================================================

.PHONY: help init dev all frontend backend stop clean logs status

CYAN  := \033[36m
GREEN := \033[32m
RESET := \033[0m
BOLD  := \033[1m

help:
	@printf "\n"
	@printf " $(CYAN)$(BOLD)Liprerie Infrastructure Control Panel$(RESET)\n"
	@printf " Developed by: $(BOLD)HoodieYlya13$(RESET) | $(BOLD)Akaby$(RESET) | $(BOLD)Algebrino$(RESET)\n"
	@printf " ====================================================================\n"
	@printf " $(BOLD)Usage:$(RESET) make <target>\n"
	@printf "\n"
	@printf " $(BOLD)Setup & Initialization:$(RESET)\n"
	@printf "   $(GREEN)init$(RESET)          - Initialize submodules and install dependencies\n"
	@printf "   $(GREEN)clean$(RESET)         - Clean all builds, cache, node_modules, and containers\n"
	@printf "\n"
	@printf " $(BOLD)Development Flow:$(RESET)\n"
	@printf "   $(GREEN)all / dev$(RESET)     - Run backend inside Docker and Next.js frontend locally\n"
	@printf "   $(GREEN)frontend$(RESET)      - Run the Next.js dev server locally with hot-reload\n"
	@printf "   $(GREEN)backend$(RESET)       - Run PostgreSQL, Mailpit, and Spring Boot inside Docker\n"
	@printf "\n"
	@printf " $(BOLD)Container Management:$(RESET)\n"
	@printf "   $(GREEN)stop$(RESET)          - Tear down all backend and database containers\n"
	@printf "   $(GREEN)logs$(RESET)          - Tail live container logs from backend stack\n"
	@printf "   $(GREEN)status$(RESET)        - Show status of active containers and endpoints\n"
	@printf "\n"

init:
	@printf " $(CYAN)--> Preparing your Liprerie local workspace...$(RESET)\n"
	@chmod +x setup.sh
	@./setup.sh

all: dev

dev:
	@printf " $(CYAN)--> Step 1/2: Spinning up containerized backend services...$(RESET)\n"
	@$(MAKE) -C backend up
	@printf " $(GREEN)--> Step 2/2: Spawning local frontend dev server...$(RESET)\n"
	@cd frontend && npm run dev

frontend:
	@printf " $(GREEN)--> Launching Next.js frontend local dev server...$(RESET)\n"
	@cd frontend && npm run dev

backend:
	@printf " $(CYAN)--> Booting backend, postgres, and mailpit containers...$(RESET)\n"
	@$(MAKE) -C backend up

stop:
	@printf " $(CYAN)--> Tearing down backend and database containers...$(RESET)\n"
	@$(MAKE) -C backend down

logs:
	@$(MAKE) -C backend logs

status:
	@printf " $(CYAN)--> Docker Container Status:$(RESET)\n"
	@docker compose -f backend/docker-compose.yaml ps
	@printf "\n"
	@printf " $(BOLD)Active Endpoints:$(RESET)\n"
	@printf "   - Frontend Web App:     $(GREEN)http://localhost:3000$(RESET)\n"
	@printf "   - Backend Spring API:   $(GREEN)http://localhost:8080$(RESET)\n"
	@printf "   - OpenAPI/Swagger Docs: $(GREEN)http://localhost:8080/swagger-ui.html$(RESET)\n"
	@printf "   - Mailpit UI (Mails):   $(GREEN)http://localhost:8025$(RESET)\n"

clean:
	@printf " $(CYAN)--> Tearing down containers and deleting database volumes...$(RESET)\n"
	@$(MAKE) -C backend clean
	@printf " $(CYAN)--> Purging frontend node_modules, build packages, and lock files...$(RESET)\n"
	@rm -rf frontend/node_modules frontend/.next || true
	@printf " $(GREEN)--> Workspace is completely cleaned! Run 'make init' to start fresh.$(RESET)\n"