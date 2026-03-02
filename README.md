# О проекте

MedTrain — это информационная система для дистанционного обучения и сопровождения профессиональной аккредитации медицинского персонала. Разработана в рамках дипломной работы студентки 4 курса Тульского государственного педагогического университета им. Л.Н. Толстого.

## Технологический стек

Frontend: Flutter (Dart)
Backend: Supabase (PostgreSQL, Auth, Storage)
Архитектура: Clean Architecture + MVVM
Управление состоянием: Provider
Навигация: GoRouter
База данных: PostgreSQL + RLS политики

## Установка и запуск
git clone https://github.com/Alegro-s/med_train.git
cd med_train
flutter pub get
flutter run -d windows

## Структура проекта
lib/
├── core/                 # Ядро приложения
│   ├── constants/        # Константы и цвета
│   ├── theme/            # Тема оформления
│   ├── router/           # Маршрутизация
│   └── utils/            # Вспомогательные функции
├── models/               # Модели данных
├── services/             # Сервисы для работы с Supabase
├── widgets/              # Переиспользуемые виджеты
└── features/             # Функциональные модули
    ├── auth/             # Авторизация
    ├── home/             # Главный экран
    ├── courses/          # Курсы и обучение
    ├── accreditation/    # Аккредитация
    ├── profile/          # Профиль пользователя
    └── notifications/    # Уведомления

## Автор
Богомолова Полина Александровна
Студентка 4 курса, группа 1521721

## Контакты
GitHub: @Alegro-s
Email: rozalityai@gmail.com
