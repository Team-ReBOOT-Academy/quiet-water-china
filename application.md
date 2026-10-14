quiet-water/
├── docs/
│   └── project-description.md
├── README.md
├── application.md
├── .env.example
├── .gitignore
├── .dockerignore
├── Dockerfile
├── cjpm.toml
├── src/
│   ├── main.cj                              ← composition root
│   ├── api/                                 ← входящий HTTP
│   │   ├── .gitkeep
│   │   ├── health/
│   │   │   ├── .gitkeep
│   │   │   └── HealthRoutes.cj              ← GET /health
│   │   ├── http/
│   │   │   ├── .gitkeep
│   │   │   └── HttpModels.cj                ← разбор запроса для /health
│   │   └── dto/
│   │       ├── .gitkeep
│   │       └── HealthResponse.cj
│   ├── application/                         ← сценарии (use cases)
│   │   ├── .gitkeep
│   │   ├── health/
│   │   │   ├── .gitkeep
│   │   │   └── GetHealthStatus.cj
│   │   ├── candle/
│   │   │   └── .gitkeep                     ← ProcessClosedCandle — позже
│   │   └── port/                            ← контракты, без реализаций
│   │       ├── .gitkeep
│   │       ├── inbound/
│   │       │   └── .gitkeep                 ← CandleListener — позже
│   │       └── outbound/
│   │           ├── .gitkeep
│   │           └── HealthProbe.cj
│   │                                        ← RecommendationPublisher, InstrumentWindowStore — позже
│   ├── domain/                              ← ядро, без HTTP
│   │   ├── .gitkeep
│   │   ├── candle/                          ← Candle, Instrument — позже
│   │   │   └── .gitkeep
│   │   ├── signal/                          ← BUY / SELL / HOLD — позже
│   │   │   └── .gitkeep
│   │   ├── recommendation/                  ← Recommendation — позже
│   │   │   └── .gitkeep
│   │   ├── walkforward/                     ← Phase, WalkForwardPolicy — позже
│   │   │   └── .gitkeep
│   │   ├── setup/                           ← RsiReversalSetup — позже
│   │   │   └── .gitkeep
│   │   └── score/                           ← SuccessRate — позже
│   │       └── .gitkeep
│   ├── adapter/                             ← реализации портов
│   │   ├── .gitkeep
│   │   ├── http/
│   │   │   ├── .gitkeep
│   │   │   └── HealthHttpServer.cj          ← TCP-сервер /health
│   │   ├── kafka/
│   │   │   ├── .gitkeep
│   │   │   ├── inbound/                     ← KafkaCandleListener — позже
│   │   │   │   └── .gitkeep
│   │   │   ├── outbound/                    ← KafkaRecommendationPublisher — позже
│   │   │   │   └── .gitkeep
│   │   │   └── dto/                         ← EventEnvelope / Candle / Recommendation DTO — позже
│   │   │       └── .gitkeep
│   │   ├── persistence/                     ← InMemoryInstrumentWindowStore — позже
│   │   │   └── .gitkeep
│   │   ├── health/
│   │   │   ├── .gitkeep
│   │   │   ├── KafkaHealthProbe.cj
│   │   │   └── CompositeHealthProbe.cj
│   │   └── config/
│   │       ├── .gitkeep
│   │       └── EnvConfig.cj
│   ├── data/                                ← persistence, пока пусто
│   │   └── .gitkeep
│   ├── resources/                           ← application.conf / логи — позже
│   │   └── .gitkeep
│   └── test/
│       ├── domain/                          ← фазы, RSI, score — позже
│       │   └── .gitkeep
│       ├── application/
│       │   └── .gitkeep
│       └── api/                             ← проверки /health рядом с dto/http (*_test.cj)
│           └── .gitkeep
