#!/bin/bash

mvn deploy:deploy-file \
    -DgroupId=io.github.envoyproxy \
    -DartifactId=envoy \
    -Dpackaging=rpm \
    -Dversion=1.6.0 \
    -Dfile=rpm/envoy-1.6.0-1.x86_64.rpm \
    -DrepositoryId=rtr-nexus \
    -Durl=http://nexus.dfw.rtrdc.net/content/repositories/releases

