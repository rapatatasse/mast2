# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
FROM ruby:3.2.2-slim-bullseye as base

# Common dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
    libpq-dev \
    postgresql-client \
    libvips \
    pkg-config \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Node.js and Yarn
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs \
  && npm install -g yarn \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /app

# Set environment
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    BUNDLE_WITHOUT="test" \
    DEBUG_ASSETS="true"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install --network-timeout 100000
RUN yarn global add postcss postcss-cli

# Debug JS dependencies and Stimulus
RUN echo "Installed Node.js version:" && node --version \
    && echo "Installed Yarn version:" && yarn --version \
    && echo "Node modules:" && ls -la node_modules \
    && echo "Stimulus modules:" && find node_modules/@hotwired -type f

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompile assets
RUN bundle exec rails assets:precompile

# Debug asset compilation
RUN echo "Listing app/assets:" && ls -la app/assets \
    && echo "Listing public/assets:" && ls -la public/assets || true \
    && echo "Listing app/assets/builds:" && ls -la app/assets/builds || true

# Stage: Assets
FROM base as assets

# Precompile assets
RUN bundle exec rails assets:precompile

# Stage: App
FROM base as app

# Copy precompiled assets from assets stage
COPY --from=assets /app/public/assets /app/public/assets

# Add user
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID ruby \
  && useradd -u $UID -g ruby -s /bin/bash -m ruby \
  && chown -R ruby:ruby /app

USER ruby

# Start the server by default, this can be overwritten at runtime
EXPOSE 8000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "8000"]
