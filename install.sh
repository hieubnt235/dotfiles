#!/bin/bash
for d in */; do
  stow -t "$HOME" "$d"
done
