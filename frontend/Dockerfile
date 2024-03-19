#Stage 1 - Install dependencies and build the app in a build environment
FROM debian:latest AS build-env

RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 sed
RUN apt-get clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="${PATH}:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

RUN flutter doctor -v
RUN flutter channel master
RUN flutter upgrade

RUN mkdir /app/
COPY . /app/
WORKDIR /app/

RUN flutter build web --release --no-tree-shake-icons

FROM nginx:1.21.1-alpine
COPY server/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80 (Nginx default)
EXPOSE 80

# Set the default command for this container (Run Nginx in the foreground)
CMD ["nginx", "-g", "daemon off;"]