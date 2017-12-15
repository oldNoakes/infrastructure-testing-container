#!/bin/bash
echo
echo "~~~~~~ Running Goss Tests against Container"
echo
goss -g docker.yml validate --format documentation
