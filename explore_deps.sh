#!/bin/bash

ldd ./qbittorrent | grep '=>' | grep -v 'not found' | awk '{ print($3) }' | xargs -I zzz rpm -q --whatprovides zzz --info | awk '{ if($1 == "Name") { print($3); } }' | sort | uniq
