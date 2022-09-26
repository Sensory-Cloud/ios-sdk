#!/bin/bash
# ------------------------------------------------------------------
# [Author] Niles Hacking (nhacking@sensoryinc.com)
# [Title] iOS cloud SDK helper script
# ------------------------------------------------------------------

USAGE="Usage: ./sc.sh [COMMAND]"

COMMANDS="
    Commands:\n
    lint | l\t\t Lint Source Files\n
    test | t\t\t Run Unit Tests\n
    testpretty | tp\t Run Unit Tests using xcpretty output\n
    genproto | gp [tag]\t Pulls and generates proto files from master or from an optional git tag\n
    doc | d\t\t Generate Documentation\n
    help | h\t\t Display This Help Message\n
"

print_helper() {
  echo
  echo ${USAGE}
  echo
  echo -e ${COMMANDS}
}

# --- Options Processing -------------------------------------------
if [ $# == 0 ] ; then
    print_helper
    exit 1;
fi

# --- Vars ---------------------------------------------------------
PROTO_PATH='./proto'
GEN_PATH='./Sources/SensoryCloud/Generated'
PROTO_REPO='git@gitlab.com:sensory-cloud/sdk/proto.git'
PROTO_BRANCH='master'

# --- Helper Functions ---------------------------------------------
gen_proto() {

  mkdir -p "${GEN_PATH}"
  for x in $(find ./proto -iname "*.proto");
  do
    
    if [[ "$x" == *'validate.proto' ]]; then
      continue
    fi

    protoc \
      --proto_path="${PROTO_PATH}" \
      --swift_opt="Visibility=Public" \
      --swift_out="${GEN_PATH}" \
      --grpc-swift_opt="Visibility=Public" \
      --grpc-swift_out="Client=true,TestClient=true,Server=false:${GEN_PATH}" \
      $x;

    echo "Generated grpc code for $x";
  done
}

# --- Body ---------------------------------------------------------
case "$1" in

  "lint"|"l")
    swiftlint
    exit 0;
    ;;

  "test"|"t")
    xcodebuild \
      -scheme SensoryCloud \
      -sdk iphoneos \
      -destination 'platform=iOS Simulator,name=iPhone 14' \
      test
    exit 0;
    ;;

  "testpretty"|"tp")
    xcodebuild \
      -scheme SensoryCloud \
      -sdk iphoneos \
      -destination 'platform=iOS Simulator,name=iPhone 14' \
      test | xcpretty
    exit 0;
    ;;

  "genproto"|"gp")
    echo "Deleting old generated code"
    rm -rf "${GEN_PATH}"

    echo "Pulling raw proto files"
    if [[ $# -eq 2 ]]; then
        git clone -b $2 "${PROTO_REPO}"
    else
        git clone -b "${PROTO_BRANCH}" "${PROTO_REPO}"
    fi

    echo "Generating proto code"
    gen_proto

    echo "Deleting raw proto files"
    rm -rf "${PROTO_PATH}"
    
    exit 0;
    ;;

  "doc"|"d")
    jazzy \
       --module SensoryCloud \
       --exclude=/*/Generated* \
       --swift-build-tool xcodebuild \
       --build-tool-arguments -scheme,SensoryCloud,-sdk,iphoneos,-destination,'name=iPhone 14'
    exit 0;
    ;;

  "help"|"h")
    print_helper
    exit 0;
    ;;

  *)
    print_helper
    exit 1;
    ;;

esac
