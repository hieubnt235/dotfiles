#!/bin/bash
for d in */; do
    stow --adopt -t "$HOME" "$d"
done
