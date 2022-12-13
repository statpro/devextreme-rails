.PHONY: all

all: publish

VERSION ?= $(shell echo "$${GITHUB_REF_NAME:-`grep VERSION lib/devextreme/rails/version.rb | sed -e 's/VERSION =//' -e 's/[ "]//g'`}")

.PHONY: publish
publish:
	@echo ""
	@echo "About to publish the package with the following version:"
	@echo $(VERSION)
	@echo ""
	yarn publish --new-version $(VERSION) --no-git-tag-version --no-commit-hooks