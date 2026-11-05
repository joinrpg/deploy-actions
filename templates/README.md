# Шаблоны манифестов

Скелет kustomize-манифестов для новых проектов. Это **не action** — копируйте
`base/` в `manifests/base` целевого репозитория и подставляйте имя приложения:

```bash
cp -r templates/base <репозиторий>/manifests/base
cd <репозиторий>/manifests/base
mv __APP_NAME__-secret.env <app>-secret.env
sed -i 's/__APP_NAME__/<app>/g' *.yaml
```

## Что внутри base

Скелет из bastilia-rating (минимальный рабочий набор для .NET-приложения
в Selectel Managed Kubernetes):

- `deployment.yaml` — Deployment с антиаффинити, probes `/health/live` и
  `/health/ready`, `imagePullSecrets: craas-auth` (создаётся интеграцией
  кластера Selectel с Container Registry);
- `service.yaml` — Service `http: 80 → http`;
- `httproute.yaml` — HTTPRoute через gateway `main` в namespace `infra`;
- `pdp.yaml` — PodDisruptionBudget `minAvailable: 1`;
- `migration-job.yaml` — Job мигратора БД (`restartPolicy: Never`,
  `backoffLimit: 0`), подключается через `run-db-migrations`;
- `kustomization.yaml` — метка `managed-by-kustomize: "true"` (`labels:` с
  `includeSelectors: true` — попадает и в selector'ы) — та же метка, что ждёт
  prune-selector `apply-with-prune` по умолчанию;
- `<app>-secret.env` — пустой placeholder: `render-deploy-manifests` заменяет
  secretGenerator своим (`behavior: replace`), наполненным из `KUBESECRET_*`
  секретов окружения. Имя файла и генератора должно совпадать с `secret-name`,
  который передаётся в `render-deploy-manifests`.

## Overlay под окружение

В оверлее (`manifests/<env>`) обычно меняют `namespace`, хосты HTTPRoute через
`patchesJson6902`, ресурсы и добавляют `images:` (либо их подставляет
`render-deploy-manifests` на время деплоя).

## Отличия от мигрированных проектов

joinrpg-net, kogda-igra и bastilia-rating исторически используют метку
`managed-by-<app>-<env>` и поэтому несут **двойную** маркировку (старая метка
зафиксирована в иммутабельных `spec.selector` Deployment'ов). Новые проекты
этой проблемы не имеют — достаточно одной `managed-by-kustomize=true`.
