
release: bundle exec rake db:migrate

web: bundle exec thin --threaded -a 0.0.0.0 -p 4567 -R config.ru start
