.PHONY: init
init:
	cp .env.sample .env
	bundle install --path vendor/bundle
