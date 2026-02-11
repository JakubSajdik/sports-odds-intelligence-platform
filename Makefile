.PHONY: dev api-dev web-dev

dev: ## Run API + web dev servers (2 terminals)
	@echo "Run these in two terminals:"
	@echo "  make api-dev"
	@echo "  make web-dev"

api-dev:
	python -m api.app

web-dev:
	cd web && npm install && npm run dev

