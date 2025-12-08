#!/usr/bin/env bash
cd ../lib
git ls-files -s * | grep -v -e "custom" -v -e "\." > ../lib.txt
