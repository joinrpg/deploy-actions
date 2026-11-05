# deploy-actions

Composite GitHub Actions для деплоя проектов joinrpg (Selectel Managed Kubernetes + Container Registry).

## Actions

По мере добавления:

- (пока пусто — по плану docs/superpowers/plans/2026-11-03-common-deploy-actions.md в joinrpg-net)

## Шаблоны

`templates/base` — скелет kustomize-манифестов (Deployment, Service, HTTPRoute,
PodDisruptionBudget, Job мигратора) для новых проектов с единой меткой
`managed-by-kustomize=true`. См. `templates/README.md`.

## Версионирование

Потребители пинуются мажорным тегом: `joinrpg/deploy-actions/<action>@v1`. Тег `v1`
двигается на последний `main` при добавлении/исправлении actions. Ломающие изменения
входов — новый мажорный тег (`v2`).

## Политика релизов тега `v1`

Тег `v1` — доверенный указатель: потребители (в т.ч. прод-деплои с kube-секретами)
выполняют ровно то, на что он указывает. Поэтому:

- `v1` двигается только на tip `main`; код попадает в `main` только после зелёного CI
  (actionlint + fixture-тесты) и ревью изменений.
- Пуш и удаление тегов в этом репозитории запрещены ruleset'ом для всех, кроме
  администраторов (обход намеренно узкий).
- Любое изменение поведения action'а при сохранении контракта входов — обычное
  движение `v1`; изменение/удаление входов — новый мажорный тег и миграция потребителей.

## Конвенция секретов

Actions не имеют доступа к контекстам `secrets`/`vars` — все секреты передаются
входными параметрами из вызывающего workflow. Общепринятые имена:

- `SELECTEL_CR_USERNAME`, `SELECTEL_CR_PASSWORD` — Container Registry Selectel;
- `SELECTEL_K8S_SERVER` — API-сервер кластера;
- `SELECTEL_DEPLOY_SA_SECRET` — YAML Secret токена сервис-аккаунта деплоя;
- `KUBESECRET_*` — секреты приложения, целиком уходящие в k8s-Secret.

Полный список и контракты входов/выходов — в `README.md` каждого action.
