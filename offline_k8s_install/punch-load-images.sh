#!/usr/bin/env bash
readonly SCRIPT_NAME="punch-images-loader"
TARGET_REGISTRY=my-registry:30005
TAR_DIRECTORY="./images_tar"

showUsage() {
  cat <<EOF
    Punch Images Loader- Load images for offline deployment

    Usage:
      ${SCRIPT_NAME}.sh [<option>...]
      ${SCRIPT_NAME}.sh [--help]

    Options:
      -d        The path of directory that contains images tar [default : current directory]
      -r        The name of your private registry to tag images [private_regisrty:port]

EOF
}

importImages(){
  for filename in $TAR_DIRECTORY/*; do
    echo $filename
    sudo ctr -n=k8s.io images import $filename 
  done

}

pushImages(){

  images=($(sudo ctr -n=k8s.io images ls -q | grep $TARGET_REGISTRY/punchplatform))

  for element in "${images[@]}"; do
      echo $element
      sudo ctr -n=k8s.io images push --plain-http=true $element
    done
}

while getopts ":hr:d:" flag
do
    case "${flag}" in
        d) TAR_DIRECTORY=${OPTARG};;
        r) TARGET_REGISTRY=${OPTARG};;
        h) showUsage
           exit
          ;;
       \?) printf "illegal option: -%s\n" "$OPTARG" >&2
           showUsage
           exit 1
          ;;
    esac
done

echo "Private Registry=$TARGET_REGISTRY, Tar Directory=$TAR_DIRECTORY" 

importImages
pushImages