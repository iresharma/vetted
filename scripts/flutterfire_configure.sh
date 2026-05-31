#!/usr/bin/env bash
# FlutterFire uses Ruby xcodeproj — system gem 1.22 can't parse Flutter SPM projects.
# Run configure through this script after: dart pub global activate flutterfire_cli
set -euo pipefail
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$GEM_HOME/bin:$PATH"
gem install xcodeproj --user-install --silent
dart pub global run flutterfire_cli:flutterfire configure "$@"
