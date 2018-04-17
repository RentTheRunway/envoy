#!/bin/bash -e

# scl devtoolset and epel repositories
yum install -y centos-release-scl epel-release

# llvm-5.0.0 repository from copr
curl -L -o /etc/yum.repos.d/alonid-llvm-5.0.0-epel-6.repo \
  https://copr.fedorainfracloud.org/coprs/alonid/llvm-5.0.0/repo/epel-6/alonid-llvm-5.0.0-epel-6.repo

# dependencies for bazel and build_recipes
yum install -y java-1.8.0-openjdk-devel unzip which openssl rpm-build \
               cmake3 devtoolset-4-gcc-c++ git golang libtool make patch rsync wget \
               clang-5.0.0 devtoolset-4-libatomic-devel llvm-5.0.0 python27 python27-python-virtualenv \
               bc zip unzip tar gzip bzip2
yum clean all

ln -s /usr/bin/cmake3 /usr/bin/cmake

# symbolic links for clang
pushd /opt/llvm-5.0.0/bin
ln -s clang++ clang++-5.0
ln -s clang-format clang-format-5.0
popd

mkdir -p /usr/lib/llvm-5.0/bin
pushd /usr/lib/llvm-5.0/bin
ln -s /opt/llvm-5.0.0/bin/llvm-symbolizer .
popd

# setup bash env
echo '. scl_source enable devtoolset-4' > /etc/profile.d/devtoolset-4.sh
echo 'PATH=/opt/llvm-5.0.0/bin:$PATH' > /etc/profile.d/llvm-5.0.0.sh

# enable devtoolset-4 for current shell
# disable errexit temporarily, otherwise bash will quit during sourcing
set +e
. scl_source enable devtoolset-4
set -e

# latest bazel - build from scratch to avoid glibc issues
BAZEL_VERSION="$(curl -s https://api.github.com/repos/bazelbuild/bazel/releases/latest | python -c "import json, sys; print json.load(sys.stdin)['tag_name']")"

wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip
unzip bazel-${BAZEL_VERSION}-dist.zip -d bazel-${BAZEL_VERSION}
pushd bazel-${BAZEL_VERSION}
./compile.sh
cp output/bazel /usr/local/bin
popd

./build_container_common.sh
