.PHONY: *

error:
	@echo "You must specify a target"
	@exit 2

setup:
	bundle install

release: build
	git stash
	git checkout gh-pages
	git ls-files -z | xargs -0 rm -f
	mv build/* .
	git add -A
	-git commit -am "updated to $(shell git rev-parse HEAD)"
	git push
	git checkout master

build:
	ruby gen.rb
