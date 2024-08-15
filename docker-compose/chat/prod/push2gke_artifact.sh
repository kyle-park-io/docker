#!/bin/bash

docker compose -f docker-compose.prod.yaml build --no-cache

PROJECT_ID=kyle-server-402706
REPOSITORY=kyle-registry
LOCATION=me-west1
IMAGE=(chat-app-client chat-app-server chat-app-envoy)
TAG=0.0.1
TAG_LATEST=latest

set -e

for i in "${!IMAGE[@]}"; do
  echo "Index: $i, Value: ${IMAGE[$i]}"

  # delete existing image
  # untag
  gcloud artifacts docker tags delete $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/${IMAGE[$i]}:$TAG --quiet || true
  gcloud artifacts docker tags delete $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/${IMAGE[$i]}:$TAG_LATEST --quiet || true
  # delete
  # --filter="tags:$TAG" --format="get(DIGEST)" --limit=1
  DIGEST=$(gcloud artifacts docker images list $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY --filter="PACKAGE: ${IMAGE[$i]}" --format="get(DIGEST)" --limit=1)
  gcloud artifacts docker images delete $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/${IMAGE[$i]}@$DIGEST --quiet || true

  # push 0.0.1
  # IMAGE_TAG=me-west1-docker.pkg.dev/kyle-server-402706/kyle-registry/chat-app-client:0.0.1
  IMAGE_TAG=$LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/${IMAGE[$i]}:$TAG
  docker push $IMAGE_TAG

  # push latest
  IMAGE_TAG_LATEST=$LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/${IMAGE[$i]}:$TAG_LATEST
  docker tag $IMAGE_TAG $IMAGE_TAG_LATEST
  docker push $IMAGE_TAG_LATEST

done
