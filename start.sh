#! /bin/bash

HOMEDIR=~/blockchain/omnicore

mkdir -p $HOMEDIR

docker run -d --name omnicore-node \
    -v $HOMEDIR:/root/.bitcoin \
    -p 18332:8332 \
    mahuaibo/omnicore:latest