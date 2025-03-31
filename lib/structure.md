lib/
├── core/
│   ├── constants/
│   ├── services/
│   └── utils/
│
├── data/
│   ├── models/            # Data models/entities
│   ├── repositories/      # Repository implementations
│   └── datasources/       # Local/Remote data sources
│
├── domain/
│   ├── repositories/      # Repository interfaces
│   └── usecases/         # Business logic use cases
│
├── presentation/
│   ├── views/            # UI Screens
│   │   └── widgets/      # Reusable widgets
│   └── viewmodels/       # ViewModels for each view
│
├── di/                   # Dependency injection
│   └── injection.dart
│
└── main.dart
