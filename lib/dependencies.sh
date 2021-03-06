install_node_modules() {
  local build_dir=${1:-}
  local has_prebuild_script=${2:-}
  local has_postbuild_script=${3:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    if [ -n "$has_prebuild_script" ]; then
      echo "Running prebuild script"
      npm run heroku-prebuild
    fi
    echo "Pruning any extraneous modules"
    npm prune --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing node modules (package.json + shrinkwrap)"
    else
      echo "Installing node modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
    if [ -n "$has_postbuild_script" ]; then
      echo "Running postbuild script"
      npm run heroku-postbuild
    fi
  else
    echo "Skipping (no package.json)"
  fi
}

rebuild_node_modules() {
  local build_dir=${1:-}
  local has_prebuild_script=${2:-}
  local has_postbuild_script=${3:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    if [ -n "$has_prebuild_script" ]; then
      echo "Running prebuild script"
      npm run heroku-prebuild
    fi
    echo "Rebuilding any native modules"
    npm rebuild 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing any new modules (package.json + shrinkwrap)"
    else
      echo "Installing any new modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
    if [ -n "$has_postbuild_script" ]; then
      echo "Running postbuild script"
      npm run heroku-postbuild
    fi
  else
    echo "Skipping (no package.json)"
  fi
}
