#!/bin/bash
# ------------------------------------------------------------------
# [Author] Niles Hacking (nhacking@sensoryinc.com)
# [Title] iOS cloud SDK helper script
# ------------------------------------------------------------------

USAGE="Usage: ./sc.sh [COMMAND]"

COMMANDS="
    Commands:\n
    lint | l\t\t Lint Source Files\n
    build | b\t\t Build Swift Package\n
    test | t\t\t Run Unit Tests\n
    genproto | gp\t\t Generate Proto Files\n
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

# --- Helper Functions ---------------------------------------------
gen_proto() {

  mkdir -p "Sources/SensoryCloud/Generated"
  for x in $(find ./Proto -iname "*.proto");
  do
    
    if [[ "$x" == *'validate.proto' ]]; then
      continue
    fi

    protoc \
      --proto_path="./Proto" \
      --swift_opt="Visibility=Public" \
      --swift_out="./Sources/SensoryCloud/Generated" \
      --grpc-swift_opt="Visibility=Public" \
      --grpc-swift_out="Client=true,TestClient=true,Server=false:./Sources/SensoryCloud/Generated" \
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
    echo "TODO"
    exit 0;
    ;;

  "genproto"|"gp")
    gen_proto
    exit 0;
    ;;

  "doc"|"d")
    jazzy \
       --module SensoryCloud \
       --exclude=/*/Generated* \
       --swift-build-tool xcodebuild \
       --build-tool-arguments -scheme,SensoryCloud,-sdk,iphoneos,-destination,'id=7517DB8B-28F4-42C5-A844-AA5E2554786E'
# TODO: proper destination selection
#        --build-tool-arguments -scheme,SensoryCloud,-sdk,iphoneos,-destination,'platform=iOS Simulator,name=iPhone 8,OS=15.0'
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