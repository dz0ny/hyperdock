FROM debian:unstable

ENV DEBIAN_FRONTEND noninteractive

# set a few bundle config variables so that a local .bundle in our development directory doesn't screw up our image
ENV BUNDLE_APP_CONFIG /apps/bundle
ENV BUNDLE_PATH /apps/gems

RUN apt-get update && apt-get install -yq bundler

# postgresql, nokogiri, and sqlite dependencies
RUN apt-get install -yq libpq-dev libxslt-dev libxml2-dev sqlite3 libsqlite3-dev libyaml-dev libreadline-dev libxml2-dev libxslt1-dev

ADD Gemfile /apps/rails/Gemfile
ADD Gemfile.lock /apps/rails/Gemfile.lock
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
RUN bundle install

WORKDIR /apps/rails

CMD ["/apps/rails/config/docker/runner"]

