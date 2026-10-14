# Quiet Water (`quiet-water`)

Student **strategy-service** for the OmSU instructor platform
([Teacher Trading Platform](https://omsu.7bits.it/)).

The service does not trade on a real exchange and does not compute a virtual
portfolio. It sits outside the platform: for every closed candle it answers
with one `BUY` / `SELL` / `HOLD` decision and serves `GET /health` diagnostics.

Author: **llnightll**  
Project document: [docs/project-description.md](docs/project-description.md)  
Service identifier / future `strategyId`: `quiet-water`  
Scaffold: **Cangjie** (`cjpm`) + HTTP on `std.net`

## Preliminary strategy

**Walk-forward “pass mark”** (quiet water — silence first, then a strike):

1. The first `N` candles per ticker collect a window; outbound signal is `HOLD` only.
2. The next `K` candles exam the already computed success formula; again `HOLD` only.
3. If the exam hit-rate is not below threshold `T`, the service starts trading.
4. The window then slides by one candle and the success formula is recomputed.
5. The entry setup is an RSI(14) reversal from the 30/70 zones; only `successRate` allows a trade.

A language model is not in the `BUY`/`SELL` loop. It is an optional “star”
after the recommendation is sent; see the project document. Assignment 1
does not implement it.

Starting thresholds (from the environment, not from code): `N=90`, `K=45`, `M=10`, `W=20`, `T=0.55`.

## Environment requirements

You can **build and run without an IDE** in two ways: a local Cangjie SDK or Docker.
One of the two is enough on the machine.

**Option A — local Cangjie SDK**

- Cangjie SDK **1.2.0** (`cjc`, `cjpm`), `CANGJIE_HOME`
- `curl` to check `/health`

**Option B — Docker only**

- Docker Engine 24+
- No SDK on the host; the image `zxilly/cangjie` builds the binary

Kafka secrets and `secretKey` are issued by the instructor separately. They are
not in Git. Sample variable names are in `.env.example`.
Until the broker is issued, the service must start in `DEGRADED` status.

## Build and run without an IDE

The commands below are the Cangjie scaffold run contract. Repeat them in CI
or on the instructor’s machine.

### cjpm

```bash
cjpm test
cjpm run
```

Or after a build, run the binary directly:

```bash
cjpm build
./target/release/bin/main
```

On Windows the executable is `target\release\bin\main.exe`.

In another terminal:

```bash
curl -s http://127.0.0.1:8888/health
```

Expected response of a live scaffold (assignment 1, Kafka not wired yet):

```json
{
  "status": "DEGRADED",
  "service": "quiet-water",
  "version": "1.0.0",
  "components": {
    "kafka": {
      "status": "DOWN",
      "details": "broker is not configured"
    }
  }
}
```

HTTP status is **200** even when `status` is `DEGRADED`.
`/health` does not require authorization.

Stop the local process with `Ctrl+C`.

### Docker (preferred “no IDE” path)

```bash
docker build -t quiet-water:1.0.0 .
docker run --rm -p 8888:8888 --name quiet-water quiet-water:1.0.0
```

Check and stop:

```bash
curl -s http://127.0.0.1:8888/health
docker stop quiet-water
```

Pass environment variables with `--env` / `--env-file`; do not bake them
into the image. Do not put passwords or keys in the repository.

The container must shut down cleanly on `SIGTERM` (`docker stop`).

## Deliberately out of this repository

- UI — portfolio observation already exists on the platform
- owned database — only in the persistence assignment
- Kafka client — next open assignment (`semester-1-broker`)
- real broker orders — the platform does not send them

Detailed boundaries, roles, and the event contract are in
[docs/project-description.md](docs/project-description.md).
Source layout is in [application.md](application.md).
