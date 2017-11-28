FROM ruby:2.4.1

RUN printf "deb http://deb.debian.org/debian testing main\ndeb http://deb.debian.org/debian testing-updates main\ndeb http://security.debian.org testing/updates main" >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get install --yes --no-install-recommends apt-transport-https=1.0.* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN echo 'deb https://deb.nodesource.com/node_6.x jessie main' > /etc/apt/sources.list.d/nodesource.list && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-get update && \
    apt-get install --yes --target-release=jessie --no-install-recommends python-pip python-yaml locales nodejs=6.* build-essential && \
    apt-get install --yes --target-release=testing --no-install-recommends git python-sphinx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN gem update --no-document --system
RUN npm install -g conventional-changelog-cli

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen
ENV LC_ALL en_US.UTF-8

RUN curl -o /tmp/chefdk.deb https://packages.chef.io/files/stable/chefdk/1.3.43/debian/8/chefdk_1.3.43-1_amd64.deb && \
    dpkg -i /tmp/chefdk.deb && \
    rm -rf /tmp/chefdk.deb

ENV APP_HOME /cookbooks/opsworks_ruby
RUN mkdir -p "$APP_HOME"

RUN gem install bundler
RUN pip install yamllint>=1

WORKDIR $APP_HOME

COPY .chef.login $APP_HOME/
RUN mkdir -p /root/.chef
RUN printf "client_key \"/cookbooks/opsworks_ruby/client.pem\"\n" >> /root/.chef/knife.rb
RUN printf "node_name \"$(cat /cookbooks/opsworks_ruby/.chef.login)\"\n" >> /root/.chef/knife.rb
RUN printf "cookbook_path \"/cookbooks\"\n" >> /root/.chef/knife.rb

COPY package.json $APP_HOME/
RUN npm install

COPY Gemfile* $APP_HOME/
RUN bundle install -j 4

COPY Berksfile* $APP_HOME/
COPY metadata.rb $APP_HOME/
COPY README.md $APP_HOME/
RUN chef exec berks

