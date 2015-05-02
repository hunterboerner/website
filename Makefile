error:
	@echo "You must specify a target"
	@exit 2

setup:
	bundle install

build:
	ruby gen.rb

release: GIT_COMMIT = $(git rev-parse HEAD)
release: build
	git stash
	git checkout gh-pages
	git ls-files -z | xargs -0 rm -f
	mv build/* .
	git add -A
	git commit -am 'updated to $(GIT_COMMIT)'
