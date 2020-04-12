#!/bin/bash

last_version=$(git fetch --tags && git tag -l "v*" | tail -n 1)
