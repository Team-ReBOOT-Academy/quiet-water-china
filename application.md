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
│   │   │   └── HealthRoutes.cj              ← GET /health (卄升卜丨力乚乞)
│   │   ├── http/
│   │   │   ├── .gitkeep
│   │   │   └── HttpModels.cj                ← разбор запроса для /health (户升尺与乞, 与丁尺工户尺乞丁凵尺卜丨, 卄乞升力乞尺与乞户升尺升丁囗尺工卜丨力乞乂, 下工尺与丁工卜丨力乞乂囗下, 囗长亅与囗卜丨, 卜丨囗丁下囗凵卜丨力亅与囗卜丨, 丁囗乃丫丁乞与)
│   │   └── dto/
│   │       ├── .gitkeep
│   │       └── HealthResponse.cj            (丁囗亅与囗卜丨, 与丁升丁凵与卜丨升从乞, 乞与亡升户乞)
│   ├── application/                         ← сценарии (use cases)
│   │   ├── .gitkeep
│   │   ├── health/
│   │   │   ├── .gitkeep
│   │   │   └── GetHealthStatus.cj           (乞乂乞亡凵丁乞)
│   │   ├── candle/
│   │   │   └── .gitkeep                     ← ProcessClosedCandle — позже
│   │   └── port/                            ← контракты, без реализаций
│   │       ├── .gitkeep
│   │       ├── inbound/
│   │       │   └── .gitkeep                 ← CandleListener — позже
│   │       └── outbound/
│   │           ├── .gitkeep
│   │           └── HealthProbe.cj           (卜丨升从乞, 户尺囗乃乞)
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
│   │   │   └── HealthHttpServer.cj          ← TCP-сервер /health (与乞尺V乞, 卄升卜丨力乚乞亡乚工乞卜丨丁, 尺乞升力尺乞贝凵乞与丁)
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
│   │   │   ├── KafkaHealthProbe.cj          (卜丨升从乞, 户尺囗乃乞)
│   │   │   └── CompositeHealthProbe.cj      (亡囗乚乚乞亡丁)
│   │   └── config/
│   │       ├── .gitkeep
│   │       └── EnvConfig.cj                 (工与___长升下长升___亡囗卜丨下工马凵尺乞力, 下尺囗从___乞卜丨V工尺囗卜丨从乞卜丨丁, 尺乞升力与丁尺工卜丨马, 尺乞升力凵工卜丨丁, 尺乞升力工卜丨丁, 尺乞升力下乚囗升丁)
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
│           └── .gitkeep                     (HealthResponse_test: 力乞马尺升力乞力亅与囗卜丨从升丁亡卄乞与亡囗卜丨丁尺升亡丁; HttpModels_test: 户升尺与乞与马乞丁卄乞升乚丁卄)
