#!/bin/bash -e

# buildifier
export GOPATH=/usr/lib/go
go get github.com/bazelbuild/buildifier/buildifier

# GCC for everything.
export CC=gcc
export CXX=g++
export THIRDPARTY_DEPS=/tmp
export THIRDPARTY_SRC=/thirdparty
DEPS=$(python <(cat /bazel-prebuilt/bazel/target_recipes.bzl; \
  echo "print ' '.join(\"${THIRDPARTY_DEPS}/%s.dep\" % r for r in set(TARGET_RECIPES.values()))"))

# TODO(htuch): We build twice as a workaround for https://github.com/google/protobuf/issues/3322.
# Fix this. This will be gone real soon now.
export THIRDPARTY_BUILD=/thirdparty_build
export CPPFLAGS="-DNDEBUG"
echo "Building opt deps ${DEPS}"
"$(dirname "$0")"/build_and_install_deps.sh ${DEPS}

echo "Building Bazel-managed deps (//bazel/external:all_external)"
mkdir /bazel-prebuilt-root /bazel-prebuilt-output
BAZEL_OPTIONS="--output_user_root=/bazel-prebuilt-root --output_base=/bazel-prebuilt-output"
cd /bazel-prebuilt
for BAZEL_MODE in opt dbg fastbuild; do
  bazel ${BAZEL_OPTIONS} build -c "${BAZEL_MODE}" --host_cxxopt="-march=core2" --host_copt="-march=core2" --cxxopt="-march=core2" --copt="-march=core2" //bazel/external:all_external
done
# Allow access by non-root for building.
chmod -R a+rX /bazel-prebuilt-root /bazel-prebuilt-output
