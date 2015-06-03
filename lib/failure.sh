warnings=$(mktemp -t heroku-buildpack-nodejs-XXXX)

failure_message() {
  local warn=$(cat $warnings)
  echo ""
  echo "We're sorry this build is failing! You can troubleshoot common issues here:"
  echo "https://devcenter.heroku.com/articles/troubleshooting-node-deploys"
  echo ""
  if [ "$warn" != "" ]; then
    echo "Some possible problems:"
    echo ""
    echo "$warn"
  else
    echo "If you're stuck, please submit a ticket so we can help:"
    echo "https://help.heroku.com/"
  fi
  echo ""
  echo "Love,"
  echo "Heroku"
  echo ""
}

warning() {
  local tip=$1
  local url=$2
  echo "- $tip" >> $warnings
  echo "  ${url:-https://devcenter.heroku.com/articles/nodejs-support}" >> $warnings
  echo "" >> $warnings
}

warn_node_engine() {
  local node_engine=$1
  if [ "$node_engine" == "" ]; then
    warning "Node version not specified in package.json" "https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version"
  elif [ "$node_engine" == "*" ]; then
    warning "Dangerous semver range (*) in engines.node" "https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version"
  elif [ ${node_engine:0:1} == ">" ]; then
    warning "Dangerous semver range (>) in engines.node" "https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version"
  fi
}

warn_node_modules() {
  local modules_source=$1
  if [ "$modules_source" == "prebuilt" ]; then
    warning "node_modules checked into source control" "https://www.npmjs.org/doc/misc/npm-faq.html#should-i-check-my-node_modules-folder-into-git-"
  elif [ "$modules_source" == "" ]; then
    warning "No package.json found"
  fi
}

warn_start() {
  local start_method=$1
  if [ "$start_method" == "" ]; then
    warning "No Procfile, package.json start script, or server.js file found" "https://devcenter.heroku.com/articles/nodejs-support#runtime-behavior"
  fi
}

warn_old_npm() {
  local npm_version=$1
  if [ "${npm_version:0:1}" -lt "2" ]; then
    local latest_npm=$(curl --silent --get https://semver.herokuapp.com/npm/stable)
    warning "This version of npm ($npm_version) has several known issues - consider upgrading to the latest release ($latest_npm)" "https://devcenter.heroku.com/articles/nodejs-support#specifying-an-npm-version"
  fi
}