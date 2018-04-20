#!/bin/bash

pushd ci/build_container
cp ../../WORKSPACE .
cp -r ../../bazel .
cp Dockerfile-centos Dockerfile

docker build .

rm Dockerfile
rm -rf bazel
rm WORKSPACE
popd
