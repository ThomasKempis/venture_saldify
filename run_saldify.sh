#!/bin/bash

flutter run -d chrome \
  --web-port=5020 \
  --dart-define=APP_MODE=saldify \
  --web-launch-url "http://localhost:5020/?appMode=saldidy"
