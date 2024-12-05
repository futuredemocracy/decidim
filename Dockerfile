ARG ruby_version=3.2.2

FROM ruby:${ruby_version}

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /code

RUN apt-get install -y git imagemagick wget \
  && apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean

RUN npm install -g npm@7.21.1
RUN npm install -g yarn@1.22.18
RUN gem install bundler --version '>= 2.3.12'

COPY Gemfile /code/Gemfile
COPY Gemfile.lock /code/Gemfile.lock

RUN bundle check || bundle install

COPY . /code

RUN #yarn install
RUN npm install

RUN bundle exec rake assets:precompile
RUN #/bin/sh -c bundle exec rake assets:precompile

#ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

EXPOSE 3000

ENTRYPOINT []

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
