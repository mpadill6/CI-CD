APP_NAME ?= python-docker-ci-demo
IMAGE ?= $(APP_NAME):dev

.PHONY: run build test lint fmt

run:
	docker compose up --build

build:
	docker build -t $(IMAGE) .

test:
	pytest -q

lint:
	flake8 app

fmt:
	black app tests

