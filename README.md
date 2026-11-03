# deploy-actions

Composite GitHub Actions для деплоя проектов joinrpg (Selectel Managed Kubernetes + Container Registry).

## Actions

По мере добавления:

- (пока пусто — по плану docs/superpowers/plans/2026-11-03-common-deploy-actions.md в joinrpg-net)

## Версионирование

Потребители пинуются мажорным тегом: `joinrpg/deploy-actions/<action>@v1`. Тег `v1`
двигается на последний `main` при добавлении/исправлении actions. Ломающие изменения
входов — новый мажорный тег (`v2`).

## Конвенция секретов

Actions не имеют доступа к контекстам `secrets`/`vars` — все секреты передаются
входными параметрами из вызывающего workflow. Общепринятые имена:

- `SELECTEL_CR_USERNAME`, `SELECTEL_CR_PASSWORD` — Container Registry Selectel;
- `SELECTEL_K8S_SERVER` — API-сервер кластера;
- `SELECTEL_DEPLOY_SA_SECRET` — YAML Secret токена сервис-аккаунта деплоя;
- `KUBESECRET_*` — секреты приложения, целиком уходящие в k8s-Secret.

Полный список и контракты входов/выходов — в `README.md` каждого action.
