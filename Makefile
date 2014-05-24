.PHONY: deploy

deploy:
	git push origin master
	git push production master

reset:
	bin/rake db:drop db:migrate db:seed
	bin/rake db:drop db:migrate db:seed RAILS_ENV=test
	redis-cli flushall

supervisor:
	supervisord -c config/supervisor/development/supervisord.conf

