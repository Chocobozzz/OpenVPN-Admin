#!/bin/bash

function echap() {
  # echap ' and \
  echo "$1" | sed s/\\\\/\\\\\\\\/g | sed s/\'/\\\\\'/g
}
