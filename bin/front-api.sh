#!/bin/sh
#
# $Id$

TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzY29wZXMiOlsic2hhcmVkOioiLCJwcml2YXRlOioiXSwiaXNzIjoiZnJvbnQiLCJzdWIiOiJnbGVuY29lX3NvZnR3YXJlIn0.bjW2-XcQ8JPIpl6TJ-a624iVsoRt9hzmfNBVh4i29tI'
URL='api2.frontapp.com'
URI=$1

curl \
  --silent \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Accept: application/json" \
  https://${URL}/${URI} | python -m json.tool
