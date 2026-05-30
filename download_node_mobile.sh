#!/bin/bash
# Downloads NodeMobile.framework (Node.js 18 for iOS)
if [ -d "NodeMobile.framework" ]; then
  echo "NodeMobile.framework already exists"
  exit 0
fi
echo "Downloading NodeMobile.framework..."
curl -L -o /tmp/NodeMobile.framework.zip \
  https://github.com/cjntjy/nodejs-mobile-ios/releases/download/v0.3.3/NodeMobile.framework.zip
unzip /tmp/NodeMobile.framework.zip -d .
echo "Done"
