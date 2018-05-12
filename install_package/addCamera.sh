#!/bin/bash
re='^4\.2\.[2-9]$'
if [[ $(/sbin/getcfg System Version) =~ $re ]]; then
  /share/CACHEDEV1_DATA/.qpkg/SolinkGateway/node32 /share/CACHEDEV1_DATA/install_package/add_camera/appAC.js
else
  /share/CACHEDEV1_DATA/.qpkg/SolinkGateway/node64 /share/CACHEDEV1_DATA/install_package/add_camera/appAC.js
fi