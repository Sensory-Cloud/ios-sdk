#!/bin/bash
# ------------------------------------------------------------------
# [Author] Bryan McGrane
# [Title] Proto Helper Script
# ------------------------------------------------------------------
VERSION=0.1
SUBJECT=pt
USAGE="Usage: pt [OPTIONS] [COMMAND]"

OPTIONS="
    Options:\n
    -h\t Helper Script Description
"

COMMANDS="
    Commands:\n
    copyproto | cp \t Copy Proto Files from Titan project\n
    publish | p\t Tag and Deploy\n
"
# --- Initialization -----------------------------------------------
set -euo pipefail
export PATH=$PATH:/usr/local/go/bin

# --- Functions ----------------------------------------------------
print_helper() {
  echo
  echo ${USAGE}
  echo
  echo -e ${OPTIONS}
  echo
  echo -e ${COMMANDS}
}

throw_not_implemented_error() {
  echo "This feature is not yet implemented!"
  exit 125;
}

set_version() {
  version=$1
  regex_version='^v[0-9]+\.[0-9]+\.[0-9]+$'

  if [[ ! ${version} =~ ${regex_version} ]]; then
    echo "Version string should be of the format v{Major}.{Minor}.{Trivial} ex: v1.2.3"
    exit 1
  fi

  # Check if version exists
  git fetch --tags
  if [ $(git tag -l "${version}") ]; then
    echo "Version ${version} already exists. Exiting."
    exit 1
  fi

  git commit -am "Release [${version}]"
  git tag ${version}
  git push --atomic origin HEAD ${version}
}

# --- Environment --------------------------------------------------

CURRENT_BRANCH=${CI_COMMIT_BRANCH:-$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)}

while getopts ":h" optname
  do
    case "$optname" in
      "h")
        print_helper
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

# --- Body --------------------------------------------------------
case "$1" in
  "copyproto"|"cp")
    cp -R ../titan/api/common/. ./common/.
    cp -R ../titan/api/health/. ./health/.
    cp -R ../titan/api/oauth/. ./oauth/.
    cp -R ../titan/api/v1/audio/. ./v1/audio/.
    cp -R ../titan/api/v1/event/. ./v1/event/.
    cp -R ../titan/api/v1/file/. ./v1/file/.
    cp ../titan/api/v1/management/device.proto ./v1/management/device.proto
    cp ../titan/api/v1/management/enrollment.proto ./v1/management/enrollment.proto
    cp -R ../titan/api/v1/video/. ./v1/video/.
    cp -R ../titan/api/validate/. ./validate/.
    exit 0;
  ;;

  "publish"|"p")
    set_version $2
  ;;

  *)
    print_helper
    exit 0;
  ;;

esac
# -----------------------------------------------------------------