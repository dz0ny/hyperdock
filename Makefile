.PHONY: deploy

deploy:
	git push origin master
	git push production master

reset:
	bin/rake db:drop db:migrate db:seed
	bin/rake db:drop db:migrate db:seed RAILS_ENV=test
	redis-cli flushall

migrate:
	bin/rake db:migrate
	bin/rake db:migrate RAILS_ENV=test

supervisor:
	supervisord -c config/supervisor/development/supervisord.conf

