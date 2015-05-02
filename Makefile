.PHONY: *

error:
	@echo "You must specify a target"
	@exit 2

setup:
	bundle install

release: GIT_COMMIT = $(git rev-parse HEAD)
release: build
	git stash
	git checkout gh-pages
	git ls-files -z | xargs -0 rm -f
	mv build/* .
	git add -A
	git commit -am 'updated to $(GIT_COMMIT)'
	git push
	git checkout master

build:
	echo "wat"
	ruby gen.rb
