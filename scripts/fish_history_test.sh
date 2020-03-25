#!/bin/bash

i=$((i+1))
while true
do
  # utctimestamp=$(date +%s)
  # echo $utctimestamp
  
  last=$(echo $i)
  ((i=i+1))
  lastfilepath="/Users/henry.warren/go/src/github.com/henrysdev/fisherman/debug/copies/history_${last}"
  newfilepath="/Users/henry.warren/go/src/github.com/henrysdev/fisherman/debug/copies/history_${i}"
  diffpath="/Users/henry.warren/go/src/github.com/henrysdev/fisherman/debug/diffs/${last}_to_${i}"
  # echo $i
  # echo $lastfilepath
  # echo $newfilepath
  cat /Users/henry.warren/.local/share/fish/fish_history > $newfilepath
  diffres=$(diff $lastfilepath $newfilepath)
  if [ "$diffres" != "" ]
  then
    echo "change detected"
    echo $diffres
    # Show positive additions Only
    diff -u $lastfilepath $newfilepath | grep -E "^\+" > $diffpath
  fi
  rm $lastfilepath
  sleep 5
done