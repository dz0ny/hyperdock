.PHONY: deploy

deploy:
	git push origin master
	git push production master

reset:
	bin/rake db:reset
	bin/rake db:reset RAILS_ENV=test
	redis-cli flushall
