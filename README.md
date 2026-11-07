# deploy-actions

Composite GitHub Actions для деплоя проектов joinrpg (Selectel Managed Kubernetes + Container Registry).

## Actions

| Action | Назначение |
|---|---|
| `setup-kubectl-context` | Установка kubectl v1.35.9 и kube-контекста из YAML Secret'а сервис-аккаунта |
| `selectel-cr-login` | Логин в Container Registry Selectel (обёртка docker/login-action) |
| `resolve-image-digests` | Резолвит digest'ы образов по тегу, отдаёт блок `images:` для kustomization |
| `render-deploy-manifests` | Пишет KUBESECRET_* в .env, дописывает secretGenerator и images в kustomization, рендерит в `kustomize_output/` |
| `apply-with-prune` | `kubectl apply --prune` с allowlist и ожиданием rollout'ов |
| `run-db-migrations` | Прогон миграций БД как k8s-Job с ожиданием и диагностикой |
| `calculate-version` | SemVer-версия по GitHubFlow из git-истории (ветки/теги) |
| `publish-dotnet-containers` | Сборка образов через `dotnet publish /t:PublishContainer` и пуш в registry |

Контракты входов/выходов — в `action.yml` каждого action.

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
