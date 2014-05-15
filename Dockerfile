FROM tianon/ruby-unicorn
RUN apt-get install -yq libpq-dev libxslt-dev libxml2-dev
ADD Gemfile /apps/rails/Gemfile
ADD Gemfile.lock /apps/rails/Gemfile.lock
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
RUN bundle install --deployment --without development test
RUN erb config/database.yml.erb > config/database.yml
