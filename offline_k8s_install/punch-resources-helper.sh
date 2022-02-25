#!/usr/bin/env bash

readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly LBLUE='\033[1;34m'
readonly NC='\033[0m'
readonly SCRIPT_NAME="punch-resources-helper"
TARGET_REGISTRY=my-registry:30005
HELM_TAG=8.0-latest
FILE="./resources.txt"

showUsage() {
  cat <<EOF
    Punch Resoures Helper- Download and save resources for offline deployment

    Usage:
      ${SCRIPT_NAME}.sh [<option>...]
      ${SCRIPT_NAME}.sh [--help]

    Options:
      -f        The path of the file that contains Punch images to download 
      -r        The name of your private registry to tag images [private_regisrty:port]
      -c        Punch Helm Charts version

EOF
}

getListofImages() {
  array_images=()

  if test -f "$FILE"; then
    # Get only lines that contains images
      IFS=$'\n' read -d "" -ra file_data < "$FILE"

      for element in "${file_data[@]}"; do
          if [[ $element == *'ghcr.io/punchplatform'* ]]; then
              IFS='/' read -a lines <<< "$element"
              image_new_tag="$TARGET_REGISTRY/${lines[1]}/${lines[2]}"
              application_name=${lines[2]}
              old_and_new_tag="$element;$image_new_tag;$application_name"
              array_images+=($old_and_new_tag)
          fi
      done
 else 
  echo " file $FILE not exist"
  exit 1
fi

}

downloadImages() {
  echo "================= Download Container Images ================="
    printf "${LBLUE}%s"
    for element in "${array_images[@]}"; do
      IFS=';' read -a lines <<< $element
      docker image pull ${lines[0]}
    done
    printf "${NC}"
}

tagImages() {
    echo "================= Tag Images Names ================="
    printf "${LBLUE}%s"
    for element in "${array_images[@]}"; do
      IFS=';' read -a lines <<< $element
      echo "${lines[0]}  -> ${lines[1]}"
      docker image tag ${lines[0]} ${lines[1]}
    done
    printf "${NC}"
}

saveImages() {
    echo "================= Tar Images ================="
    printf "${LBLUE}%s"
    mkdir -p images_tar
    for element in "${array_images[@]}"; do
      IFS=';' read -a lines <<< $element
      IFS=':' read -a app_names <<< ${lines[2]}
      docker save ${lines[1]} -o images_tar/${app_names[0]}-${app_names[1]}.tar
      echo "${lines[1]}  -> ${app_names[0]}-${app_names[1]}.tar"
    done
    echo "Create a zip archive of tar images"
    zip images_tar.zip -r images_tar
    printf "${NC}"

}

saveHelmsCharts() {
    echo "================= Get Helms Charts ================="
    printf "${LBLUE}%s"
    mkdir -p punch_charts
    wget https://github.com/punchplatform/punch-helm/raw/master/operator-crds-$HELM_TAG.tgz  -O punch_charts/operator-crds-$HELM_TAG.tgz 
    wget https://github.com/punchplatform/punch-helm/raw/master/operator-$HELM_TAG.tgz  -O punch_charts/operator-$HELM_TAG.tgz 
    wget https://github.com/punchplatform/punch-helm/raw/master/artifacts-$HELM_TAG.tgz  -O punch_charts/artifacts-$HELM_TAG.tgz 

    echo "Create a zip archive of tar images"
    zip punch_charts.zip -r punch_charts
    printf "${NC}"
    }

while getopts ":hr:f:c:" flag
do
    case "${flag}" in
        f) FILE=${OPTARG};;
        r) TARGET_REGISTRY=${OPTARG};;
        c) HELM_TAG=${OPTARG};;
        h) showUsage
           exit
          ;;
       \?) printf "illegal option: -%s\n" "$OPTARG" >&2
           showUsage
           exit 1
          ;;
    esac
done

echo "Private Registry=$TARGET_REGISTRY, Resources File=$FILE, Punch Helm Chart Version=$HELM_TAG" 

getListofImages
downloadImages
tagImages
saveImages
saveHelmsCharts
