#!/bin/bash

flutter run -d chrome \
  --web-port=5010 \
  --dart-define=APP_MODE=redventas \
  --web-launch-url "http://localhost:5010/?appMode=redventas"
