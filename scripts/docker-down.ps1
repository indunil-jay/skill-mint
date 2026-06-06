$composeFile = Join-Path $PSScriptRoot "..\infrastructure\compose\docker-compose.yml"
docker compose -f $composeFile down $args
