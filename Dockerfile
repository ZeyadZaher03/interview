FROM ruby:3.1

ENV RACK_ENV=production

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["ruby", "/app/scripts/crawler_pusher.rb"]
