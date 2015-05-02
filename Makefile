error:
	@echo "You must specify a target"
	@exit 2

setup:
	bundle install

build:
	ruby gen.rb

release: build
	git stash
