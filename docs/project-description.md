# Quiet Water (`quiet-water`) — trading strategy service intent

Author: **llnightll**  
Platform: OmSU instructor stand [Teacher Trading Platform](https://omsu.7bits.it/)  
Service identifier (`service`, future `producer` / `strategyId`): `quiet-water`  
Scaffold stack: **Cangjie 1.2.0 + `cjpm` + HTTP on `std.net`** (no implementation code in this document — intent only)

This document lives in Git next to the code and is versioned with it. It covers assignment 1: project definition, boundaries, interactions, composition, roles, and tools.

Contents:

1. [Project definition](#1-project-definition)
2. [Project boundaries](#2-project-boundaries)
3. [Interactions with external systems](#3-interactions-with-external-systems)
4. [Solution composition](#4-solution-composition)
5. [Roles and responsibility](#5-roles-and-responsibility)
6. [Tooling choices](#6-tooling-choices)

---

## 1. Project definition

### Name and purpose

**Quiet Water** is a student *strategy-service*. It sits **outside** the instructor platform and answers every closed candle of a run with one decision: `BUY`, `SELL`, or `HOLD`.

The service is not an exchange, not a broker, and not a student cabinet. It does not execute orders and does not compute a virtual portfolio: that is the platform’s zone. Its zone is **a decision for one candle** and compliance with the event contract.

### Trading idea under test

Hypothesis: on MOEX one-minute candles a raw setup (RSI reversal) produces too many false entries. It is worth trading only when two conditions hold at the same time:

1. the closed bar has a **price setup**;
2. in a recent window the same setups **worked more often than not** (success formula / counter).

While there is not enough data, the service **stays silent**. Hence the name: quiet water first; a strike only after the exam.

The algorithm is **walk-forward**, three phases per instrument:

| Phase | Candles | What the service does | Outbound signal |
|---|---|---|---|
| A. Collect | `1 … N` | accumulates OHLC, computes the success formula on this stretch | `HOLD` only |
| B. Exam | `N+1 … N+K` | applies the formula **without fitting** and checks it against the outcome after `M` bars | `HOLD` only |
| C. Trade | thereafter | slides the window by one candle, recomputes the score, trades when the pass mark is met | `BUY` / `SELL` / `HOLD` |

If the live score drops, a **circuit breaker** turns on: `HOLD` again and one new exam on the next `K` bars. A full `K` quarantine is **not** repeated on every step of phase C — otherwise the service would almost never enter the market.

**Setup (deterministic rule).** Mean-reversion on RSI(14):

- `BUY` candidate: RSI was below the oversold zone and the current candle close is above the previous close;
- `SELL` candidate: RSI was above the overbought zone and the close is below the previous close;
- otherwise there is no setup → `HOLD`.

**Success formula.** When such a setup already occurred, look at price after `M` candles:

- BUY succeeds if `close[t+M] > close[t]`;
- SELL succeeds if `close[t+M] < close[t]`.

`successRate = successes / W` over the last completed setups of the same direction.

**Decision in phase C:**

- there is a setup and `successRate ≥ T` and the exam is passed → the setup side;
- otherwise → `HOLD`.

Starting parameters (all from environment variables, not literals in code):

| Parameter | Meaning | Starting value |
|---|---|---|
| `N` | training-window length | 90 |
| `K` | exam length | 45 |
| `M` | success-check horizon | 10 |
| `W` | how many past setups enter the score | 20 |
| `T` | pass mark | 0.55 |
| `RSI_PERIOD` | RSI period | 14 |
| `RSI_OVERSOLD` / `RSI_OVERBOUGHT` | setup zones | 30 / 70 |

Bar `t` success is visible only at `t+M`. The last `M` exam bars do not count — otherwise that would be looking into the future.

**Star (not on the critical path).** After a recommendation is sent, a background adjustment may slightly shift the **next** bar’s `confidence` (for example within ±0.05). It does not change the trade side (`BUY`/`SELL`). Numerical correlation and hit-rate are computed by the service code, not by a language model. If the model is late or unavailable, the contribution is zero.

### Problem being solved

The platform requires an answer on **every** closed candle, with a strict binding of `runId` / `sourceEventId` / `instrument` / `sequenceNumber`. On a 1-minute realtime run you cannot:

- trade every bar;
- fit the formula on the same candles used for evaluation;
- put an external LLM into the decision loop (latency, non-determinism, future idempotency).

The service must be able to stay silent, pass an exam on a delayed window, and remain reproducible.

### Goals

1. Fix the service’s place: outside the platform, via Kafka, without a UI.
2. Test one hypothesis: setup + pass mark, not “a model guesses the market”.
3. Meet the course contract: health, configuration from the environment, a container, documentation in Git.

### Main tasks

1. Keep, per ticker, its own candle window and phase (`LEARN` / `EXAM` / `TRADE` / `HALT`).
2. Compute the RSI setup and a rolling `successRate` without looking into the future.
3. Publish one recommendation per candle in the platform contract.
4. Serve `GET /health` without authorization.
5. Read secrets and thresholds only from environment variables.

### Expected result

- this document in Git;
- a runnable Cangjie scaffold: the process starts, shuts down cleanly, `GET /health` returns HTTP 200;
- a README that lets you build and run the service without an IDE;
- on later assignments — Kafka wiring and phases A–C in the live cycle.

Right now (assignment 1) the algorithm **does not trade** at runtime: the scaffold starts HTTP and reports that the broker is not configured (`DEGRADED`). The algorithm intent is already fixed so later stages do not break it.

---

## 2. Project boundaries

### In scope

- ingest of a closed candle (once Kafka exists) and a short in-process window;
- setup calculation, success formula, walk-forward phases;
- publishing a trade recommendation;
- HTTP diagnostics `GET /health`;
- configuration via the environment;
- clean process shutdown (SIGTERM in a container).

### Explicitly out of scope

| What | Who owns it |
|---|---|
| Starting and stopping replay, choosing instruments and timeframe | instructor platform |
| Market-data supply | platform’s external vendor, not the student |
| Virtual execution, fees, portfolio, groups | platform |
| Dashboard UI, practice, course documentation | platform (`omsu.7bits.it`) |
| Real broker orders | nobody on this stand: the platform does not send them |
| Issuing the Kafka login, `secretKey`, topic name | instructor |
| Submitting homework through a UI form | there is no such form; submission = Git + a working service |
| LLM training and online fine-tuning on the current run | not in scope |

### Data and decisions the service controls

Controls:

- its `signal` and `confidence` for a specific candle;
- `suggestedQuantity` (0 on `HOLD` / warmup / exam, 1 on entry);
- `dataQuality` and `reason` / `metadata` text;
- its own Kafka consumer `group.id`;
- process readiness (health).

Does not control:

- whether the platform consensus window converges;
- whether the recommendation is executed;
- how portfolio value changes;
- which tickers the instructor included in the run.

### Who it interacts with

| Party | Type | Needed already in assignment 1? |
|---|---|---|
| Student developer (`llnightll`) | person | yes: run, read logs |
| Instructor | person, stand owner | yes: will issue the broker later |
| Teacher Trading Platform | external IS | yes as a counterpart in meaning; network — from the next assignment |
| Apache Kafka of the course stand | broker | in the boundaries, not wired in the scaffold |
| Language model (star) | external HTTP API | optional on later stages only |
| Browser / curl | health client | yes |

The service has no “cabinet” users. The only machine HTTP client is liveness/readiness probes (instructor, Docker, the developer).

---

## 3. Interactions with external systems

### 3.1. Instructor platform + Kafka

The platform talks to the student service **not over REST**, but via events in a protected Kafka.

**Known from stand documentation (checked 2026-10-11):**

- protocol: `SASL_SSL`, mechanism `SCRAM-SHA-512`;
- instructor-issued parameters: `bootstrap.servers`, login, password, candle topic name, CA if required;
- the active stand run was `REALTIME`, timeframe `1m`, topic like `market.candle.internal`;
- run instruments: `SBER`, `T`, `TATN`, `GAZP`, `MAGN`, `MOEX`, `OZON`;
- outbound recommendation event type: `strategy.recommendation.created`, `schemaVersion` `1.0`;
- candle → recommendation link: `sourceEventId`, `runId`, `instrument`, `sequenceNumber`.

**Inbound (when the broker exists).** Closed-candle event. Expected envelope fields: `eventId`, `eventType`, `schemaVersion`, `occurredAt`, `correlationId`, `causationId`, `producer`, `payload` (instrument, OHLC, `runId`, `sequenceNumber`).

**Outbound.** One recommendation per candle. Required `payload` fields per platform docs: `recommendationId`, `sourceEventId`, `runId`, `secretKey`, `strategyId`, `accountId`, `groupId`, `sessionId`, `instrument`, `sequenceNumber`, `signal`, `confidence`, `suggestedQuantity`, `dataQuality`.

**Authentication.**

- to Kafka — SCRAM login/password, TLS;
- `secretKey` in the recommendation payload — key issued by the instructor when the service was registered;
- `GET /health` **without** authorization (assignment requirement).

HTTP Basic on nginx (`realm="Teacher platform"`) protects the **course website**, not our process. The service does not use those credentials.

**Constraints.**

- do not hard-code internal platform container addresses;
- each instance has its own `group.id`, otherwise students share a message partition;
- `auto.offset.reset=earliest` on first connect;
- repeating the same candle must yield the same decision (groundwork for semester-2 idempotency);
- the answer must be fast: an LLM must not sit before `produce`.

**Errors and degradation.**

| Situation | Behaviour |
|---|---|
| No `KAFKA_BOOTSTRAP_SERVERS` / login / topic | health: `kafka=DOWN`, overall status `DEGRADED`, process stays up |
| Broker unreachable | health `DOWN`, reconnect; HTTP health is still 200 |
| Incomplete candle sequence | `HOLD`, `confidence=0`, `dataQuality` is not `OK` |
| Unknown instrument | ignore or `HOLD` with a reason in `metadata` (to be clarified) |
| Stale `secretKey` | the platform rejects the recommendation; the service learns this from a result event once that is wired |

### 3.2. HTTP health (this repository)

- method: `GET /health`;
- authorization: none;
- successful transport: **always HTTP 200**, even if components are degraded;
- body: `status`, `service`, `version`, `components`.

Scaffold example (broker not issued yet):

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

### 3.3. Language model (star, not in the scaffold)

- direction: outbound HTTPS after `produce`;
- model input: the already accepted decision and bar features, not “decide for me”;
- output: a bounded adjustment to the next `confidence`;
- authentication: API key from the environment;
- error / timeout: adjustment 0.

### Assumptions and open questions

1. **Exact candle JSON** is not yet contracted by code in this repository. The reference is the stand chapter “Closed candle event”. Open until the broker assignment.
2. The recommendation-result topic name and registration heartbeat will come from instructor docs, not guessed.
3. `accountId` / `groupId` / `sessionId` are issued by the instructor; `.env.example` has placeholders.
4. The platform does not send real orders — a documentation fact, not a hypothesis.
5. An LLM is not a criterion of assignment 1.

---

## 4. Solution composition

Only nodes this service **actually** needs. Assignment 1 does not introduce a separate UI or its own DBMS: there is nothing to fill a screen with, and nothing that must survive restarts until the persistence assignment.

| Component | Purpose | Responsibility |
|---|---|---|
| **Server application (Cangjie executable)** | the only runnable node | HTTP health, process lifecycle, later the “candle → decision → produce” loop |
| **Strategy module (same process)** | walk-forward, RSI setup, success formula | does not know HTTP or Kafka headers |
| **Message broker (course Kafka)** | event transport | owned by the stand; our service is a client |
| **Environment configuration** | thresholds, addresses, secrets | all values from env, zero secrets in Git |
| **Docker container** | run without an IDE | Cangjie image, health port, SIGTERM |
| **Project document + README** | intent and reproduction | live in the same repository |

**Why there is no UI.** Portfolio observation already exists on the platform. A second dashboard is out of scope.

**Why there is no database in the scaffold.** A window of `N+K` one-minute candles is kept in memory. Persistence is a separate closed semester-1 assignment (`semester-1-persistence`). When it opens, a storage node appears — not earlier.

**Why there is no separate “ML service”.** The success formula is ordinary arithmetic over OHLC. A dedicated inference runtime is not needed.

Diagram:

```
[instructor / data vendor]
              │ candles
              ▼
         [stand Kafka]
          │           ▲
   consume│           │ produce recommendation
          ▼           │
     [quiet-water process: strategy + std.net health]
          │
          └── GET /health  ← curl / Docker / instructor
```

---

## 5. Roles and responsibility

Only roles without which the project cannot be explained. “Product owner”, “security analyst”, “devops of a separate company” are not introduced.

### People

| Role | Who | Responsibility |
|---|---|---|
| **Customer** | course instructor | formulates the event contract, opens assignments, starts a run, watches portfolios |
| **Developer** | student `llnightll` | document, scaffold, algorithm, secrets not in Git, service answers candles |
| **Operator** | the same student in the runner role | builds the image or uses `cjpm`, sets env, watches health and logs, stops the process |
| **External-system administrator** | instructor-platform administrator | Kafka, accounts, topics, keys; our repository does not manage that |
| **Market-data owner / vendor** | stand vendor (not the student) | historical or realtime candles; does not connect to `quiet-water` directly |

### Machines

| Role | Responsibility |
|---|---|
| Service `quiet-water` | decision and health |
| Platform | candle stream, key check, virtual portfolio |
| Kafka | delivery, not business logic |

There is no “user of our service UI”: UI belongs to the platform.

---

## 6. Tooling choices

| Area | Choice | Why this, not something else |
|---|---|---|
| Language | **Cangjie 1.2.0** (`cjc`) | chosen for this repository; static typing fits a JSON event contract; local SDK and container share the same toolchain |
| Package / build | **`cjpm`** (`cjpm.toml`) | official Cangjie package manager: `cjpm test`, `cjpm build`, `cjpm run` without an IDE |
| HTTP | **`std.net` TCP** (`TcpServerSocket`) | assignment 1 only needs `GET /health`; `stdx.net.http` is not required for the scaffold |
| Serialization | **explicit JSON DTO** (`HealthResponse`) | the health body is built in code; no hidden reflection mapper in the scaffold |
| Broker | **course Kafka** of the platform | the stand has no other transport; the client appears in the broker assignment, not in the scaffold |
| DBMS | **none in assignment 1** | appears with the persistence assignment; Postgres is not pulled in “for later” |
| Documentation | **Markdown in `docs/`** | assignment requirement: the document is versioned with the code; Confluence/Wiki would split intent from the repository |
| Tasks | **practice on `omsu.7bits.it` + Git commits** | a separate Jira for one student service is not needed |
| Git hosting | wherever the student publishes the course repository | the instructor issues / accepts the URL; hosting is not hard-coded |
| Tests | **`cjpm test`** (`*_test.cj` next to DTO/HTTP) | `/health` JSON and request parsing without binding a network port |
| CI | **`cjpm` and Docker commands in the README** | a separate cloud CI is optional while the instructor builds locally or in a container |
| Container | **`zxilly/cangjie:nightly` → `nightly-slim`** | compile in the SDK image, run a native binary as PID 1 so `docker stop` delivers SIGTERM |
| Local run | `cjpm run` or Docker | without an IDE; on Windows the binary is `target\release\bin\main.exe` |
| Secrets | **environment variables**, sample `.env.example` | passwords and `secretKey` are not committed |
| LLM | not a scaffold dependency | the star is described; it is not in `cjpm.toml` |

Alternatives rejected for the scaffold:

- Kotlin / Ktor / Gradle / a JVM image — that is a different repository stack, not this Cangjie implementation;
- wiring Kafka “just in case” in assignment 1 — would not build without issued keys and would break “scaffold without secrets”.
