# fluentd/Dockerfile

# Use the official Fluentd image as a base
FROM fluent/fluentd:v1.14-1

# Switch to root user to install gems
USER root

# Install build dependencies, then install gems, then remove dependencies
RUN apk add --no-cache \
    build-base \
    ruby-dev \
    && gem install fluent-plugin-mongo -v 1.5.0 \
    && apk del build-base ruby-dev

 # Switch back to the fluentd user
 USER fluent

