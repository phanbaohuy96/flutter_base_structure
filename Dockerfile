# First stage: build the Flutter web app
FROM dart:stable AS builder

# Set Flutter version
ENV FLUTTER_VERSION=3.41.7

# Set path
ENV FLUTTER_HOME=/flutter
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

# Clone Flutter SDK at specific version
RUN git clone --branch ${FLUTTER_VERSION} --depth 1 https://github.com/flutter/flutter.git $FLUTTER_HOME

# Enable web support
RUN flutter config --enable-web

# Pre-cache required Flutter web artifacts (faster than flutter doctor)
RUN flutter precache --web

# Set working directory
WORKDIR /app

# Copy project files
COPY . .
RUN env

# Run build web script
ARG ENVIRONMENT=dev
ENV ENVIRONMENT=${ENVIRONMENT}

ARG APP_CONFIG=""
ENV APP_CONFIG=${APP_CONFIG}

# Write env file
RUN if [ -z "$APP_CONFIG" ]; then \
  echo "Argument not provided" ; \
else \
  echo -n "$APP_CONFIG" | base64 --decode > /app/apps/main/.env ; \
fi

RUN /bin/bash build_web.sh -a main -e ${ENVIRONMENT}

# Serve stage
FROM nginx:alpine

# Copy environment variables
COPY --from=builder /app/apps/main/.env /usr/share/nginx/html/m/

# Copy built web files from build stage
COPY --from=builder /app/apps/main/build/web /usr/share/nginx/html/m/

# Copy nginx config
COPY --from=builder /app/apps/main/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 3000
EXPOSE 3000

# Start nginx
CMD ["/bin/sh", "-c", "sed -i 's/listen  .*/listen 3000;/g' /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]