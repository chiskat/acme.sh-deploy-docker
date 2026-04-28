ACMEVERSION=$(curl -fsSL 'https://hub.docker.com/v2/repositories/neilpang/acme.sh/tags/?page_size=10' | grep -oE '"name":"[0-9]+\.[0-9]+\.[0-9]+"' | cut -d'"' -f4 | sort -V | tail -n1)

IMAGE_VERSION="acme_$ACMEVERSION"

CALVER=$(date -d "@$(($(date +%s) + 8 * 3600))" "+%Y.%-m.%-d")

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg ACMEVERSION="$ACMEVERSION" \
  --progress plain \
  --push \
  -t "chiskat/acme.sh-deploy-docker:$IMAGE_VERSION" \
  .

docker buildx imagetools create -t "chiskat/acme.sh-deploy-docker:$CALVER" "chiskat/acme.sh-deploy-docker:$IMAGE_VERSION"

docker buildx imagetools create -t "chiskat/acme.sh-deploy-docker:latest" "chiskat/acme.sh-deploy-docker:$IMAGE_VERSION"

docker run --rm \
  -e PUSHRM_TARGET="docker.io/chiskat/acme.sh-deploy-docker" \
  -e PUSHRM_SHORT="Acme.sh $ACMEVERSION with server-side deploy dependencies." \
  -e DOCKER_USER="chiskat" \
  -e DOCKER_PASS="$DOCKER_PASS" \
  -e PUSHRM_FILE="/repo/README.md" \
  -v "./README.md:/repo/README.md" \
  chko/docker-pushrm:1
