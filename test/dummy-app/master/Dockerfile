# This is the canonical specification of MRI ruby interpreter version for this project: the Docker
# container locks the Ruby version, so we need not use rbenv or rvm.
FROM ruby:2.7

RUN apt-get update && \
    apt-get install --yes --no-install-recommends ca-certificates redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN gem update --no-document --system

# some cribbing from https://robots.thoughtbot.com/rails-on-docker

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Freeze the dependencies into a layer (memoized by Docker with the hashes of the Rubygems
# dependency control files)
ADD Gemfile* $APP_HOME/
RUN gem install bundler
RUN bundle install -j 4

# Note that this line is only used for prod/testing builds; for dev cycle use, the copy of the code
# that is added to the container here at build type is shadowed by the mounted volume of ., which
# allows for the developer to work without building new docker layers every edit cycle.
ADD . $APP_HOME
