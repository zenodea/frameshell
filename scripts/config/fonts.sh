#!/usr/bin/env bash

fc-list :spacing=mono family | sed 's/,.*//' | sort -u
