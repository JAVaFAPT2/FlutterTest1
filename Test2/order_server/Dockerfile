# --- Build stage
FROM dart:stable AS build
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/server.dart -o build/server

# --- Runtime stage
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /runtime/ /runtime/
COPY --from=build /app/build/server /app/server

EXPOSE 8080
CMD ["/app/server"] 