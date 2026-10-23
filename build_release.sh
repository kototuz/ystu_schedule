#!/usr/bin/sh
version_tag=$(git tag --contains)
if [ "$version_tag" = "" ]; then
  echo "It is not a release commit. Give it a version tag (e.g. v42)"
  exit 1
fi

flutter build apk --release --dart-define="VERSION_TAG=$version_tag"
