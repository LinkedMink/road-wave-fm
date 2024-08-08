# road-wave-fm

```sh
docker buildx build ./ \
  --platform "linux/amd64" \
  --tag "linkedmink/node-pnpm:latest" \
  --progress "plain"

docker buildx build ./ \
  --platform "linux/amd64,linux/amd64/v3,linux/arm64" \
  --tag "linkedmink/node-pnpm:latest" \
  --progress "plain"
```
