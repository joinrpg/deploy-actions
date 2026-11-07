$ErrorActionPreference = 'Stop'

# Все значения приходят через env от action.yml (MIGRATION_*).

#Add new generated secret, replace old migration job (первый прогон — create,
#т.к. replace --force на несуществующей Job падает с NotFound)
&"kubectl" "--%" "replace --force --save-config -f $env:MIGRATION_SECRET_GLOB -n $env:MIGRATION_NAMESPACE"
if ($LastExitCode -ne 0) {exit $LastExitCode}

&"kubectl" "--%" "get job $env:MIGRATION_JOB_NAME -n $env:MIGRATION_NAMESPACE" 2>$null | Out-Null
if ($LastExitCode -ne 0) {
  Write-Output "job/$env:MIGRATION_JOB_NAME not found, creating"
  &"kubectl" "--%" "create -f $env:MIGRATION_MANIFEST -n $env:MIGRATION_NAMESPACE"
} else {
  &"kubectl" "--%" "replace --force --save-config -f $env:MIGRATION_MANIFEST -n $env:MIGRATION_NAMESPACE"
}
if ($LastExitCode -ne 0) {exit $LastExitCode}

Write-Output "Waiting for job/$env:MIGRATION_JOB_NAME to be completed or failed..."

$deadline = (Get-Date).AddMinutes([int]$env:MIGRATION_TIMEOUT_MINUTES)

#Keep waiting while job is not completed or failed
while ($true){

  if ((Get-Date) -gt $deadline) {
    Write-Error "Timeout waiting for job/$env:MIGRATION_JOB_NAME"
    exit 1
  }

  $status = &"kubectl" "--%" "get job $env:MIGRATION_JOB_NAME -n $env:MIGRATION_NAMESPACE -o json" | ConvertFrom-Json
  if ($LastExitCode -ne 0) {exit $LastExitCode}
  $conditions = $status.status.conditions
  if ($conditions) {
      foreach ($condition in $conditions) {
      if ($condition.type -eq "Complete" -and $condition.status -eq "True") {
          Write-Output "✅ Job завершен успешно!"
          exit 0
      }
      elseif ($condition.type -eq "Failed" -and $condition.status -eq "True") {
          Write-Output "Migration has failed. Migration's job pod info:"
          &"kubectl" "--%"  "get pods -n $env:MIGRATION_NAMESPACE --selector=job-name=$env:MIGRATION_JOB_NAME -o=yaml"
          exit 1
      }
      }
  }


  #Check last event for error. Must throw an error if, for instance, namespace CPU quota was exceeded
  $LastEventForJob = &"kubectl" "--%" "get events -n $env:MIGRATION_NAMESPACE --sort-by=.metadata.creationTimestamp --field-selector involvedObject.kind=Job,involvedObject.name=$env:MIGRATION_JOB_NAME -o jsonpath='{.items[-1:].message}'"
  if ($LastEventForJob -imatch "^'Error .*") { throw $LastEventForJob }

  &"kubectl" "--%" "logs -n $env:MIGRATION_NAMESPACE --follow job/$env:MIGRATION_JOB_NAME"
  Start-Sleep 3
  }
