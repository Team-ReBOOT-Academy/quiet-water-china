# Каркас собирается тем же toolchain, что и локальный cjpm (SDK 1.2).
# Образ zxilly/cangjie:nightly содержит компилятор и runtime без IDE на хосте.
FROM zxilly/cangjie:nightly AS build

WORKDIR /workspace
COPY cjpm.toml ./
COPY src ./src

RUN cjpm build

FROM zxilly/cangjie:nightly-slim

WORKDIR /app
COPY --from=build /workspace/target/release/bin/main /app/quiet_water

ENV HTTP_HOST=0.0.0.0
ENV HTTP_PORT=8888
ENV SERVICE_NAME=quiet-water
ENV SERVICE_VERSION=1.0.0

EXPOSE 8888

# PID 1 — сам бинарь, чтобы docker stop отправил SIGTERM процессу сервиса.
ENTRYPOINT ["/app/quiet_water"]
