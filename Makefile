# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Running experiments locally.

run-experiment stop-experiment: export COMPOSE_PROJECT_NAME := fuzzbench
run-experiment stop-experiment: export COMPOSE_FILE := compose/fuzzbench.yaml
run-experiment:
	docker-compose up --build --scale worker=2 --detach
	docker-compose logs --follow run-experiment
	docker-compose down

# Running this is only necessary if `run-experiment` was interrupted and
# containers were not cleaned up.
stop-experiment:
	docker-compose down

# Development.

run-end-to-end-test stop-end-to-end-test: export COMPOSE_PROJECT_NAME := e2e-test
run-end-to-end-test stop-end-to-end-test: export COMPOSE_FILE := compose/fuzzbench.yaml:compose/e2e-test.yaml
run-end-to-end-test:
	docker-compose build
	docker-compose up --detach queue-server
	docker-compose up --scale worker=3 run-experiment worker
	docker-compose run run-tests; STATUS=$$?; \
	docker-compose down; exit $$STATUS

# Running this is only necessary if `run-end-to-end-test` was interrupted and
# containers were not cleaned up.
stop-end-to-end-test:
	docker-compose down

include docker/generated.mk

SHELL := /bin/bash
VENV_ACTIVATE := .venv/bin/activate

# Fuzzbench-Orig
# ${VENV_ACTIVATE}: requirements.txt
# 	python3.10 -m venv .venv || python3 -m venv .venv
# 	source ${VENV_ACTIVATE} && python3 -m pip install --upgrade pip setuptools && python3 -m pip install -r requirements.txt

${VENV_ACTIVATE}: requirements.txt
	python3.10 -m venv .venv || python3 -m venv .venv
	source ${VENV_ACTIVATE} && python3 -m pip install --upgrade pip setuptools && \
	python3 -m pip install --retries=20 --timeout=1000 -r requirements.txt

# @Adian: use Chinese (e.g., nju, utsc, tsinghua, aliyun) source when pip install
# SRC_INDEX := https://mirrors.aliyun.com/pypi/simple
# SRC_INDEX := https://pypi.tuna.tsinghua.edu.cn/simple
# SRC_INDEX := https://mirrors.ustc.edu.cn/pypi/web/simple
# SRC_INDEX := https://mirrors.nju.edu.cn/pypi/web/simple
# ${VENV_ACTIVATE}: requirements.txt
# 	python3.10 -m venv .venv || python3 -m venv .venv
# 	source ${VENV_ACTIVATE} && python3 -m pip install --upgrade pip setuptools \
# 	&& python3 -m pip install -i ${SRC_INDEX} --retries 20 --timeout 1000 -r requirements.txt
# ${VENV_ACTIVATE}: requirements.txt
# 	python3.10 -m venv .venv || python3 -m venv .venv
# 	source ${VENV_ACTIVATE} && python3 -m pip install --upgrade pip setuptools \
# 	&& python3 -m pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple \
# 	|| python3 -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple \
# 	|| python3 -m pip install -r requirements.txt -i https://mirrors.ustc.edu.cn/pypi/web/simple \
# 	|| python3 -m pip install -r requirements.txt -i https://mirrors.nju.edu.cn/pypi/web/simple

install-dependencies: ${VENV_ACTIVATE}

docker/generated.mk: docker/generate_makefile.py docker/image_types.yaml fuzzers benchmarks ${VENV_ACTIVATE}
	source ${VENV_ACTIVATE} && PYTHONPATH=. python3 $< $@

presubmit: install-dependencies
	source ${VENV_ACTIVATE} && python3 presubmit.py

test: install-dependencies
	source ${VENV_ACTIVATE} && python3 presubmit.py test

format: install-dependencies
	source ${VENV_ACTIVATE} && python3 presubmit.py format

licensecheck: install-dependencies
	source ${VENV_ACTIVATE} && python3 presubmit.py licensecheck

lint: install-dependencies
	source ${VENV_ACTIVATE} && python3 presubmit.py lint

typecheck: install-dependencies
	source ${VENV_ACTIVATE} && python3 presubmit.py typecheck

install-docs-dependencies: docs/Gemfile.lock
	cd docs && bundle install

docs-serve: install-docs-dependencies
	cd docs && bundle exec jekyll serve --livereload
