FROM ruby:3.3.5

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    imagemagick

# Set working directory
WORKDIR /app

# Install bundler and gems
COPY Gemfile ./
RUN gem install bundler && bundle install

# Copy the rest of the application code
COPY . .

# Add a script to be executed every time the container starts.
COPY bin/docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
