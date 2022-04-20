## Punch Offline Installation

The following two scripts are usefull to install Punch K8s operator and Punch images on a offline Platform.

### Punch Resources Helper

This script can be used to deploy Punch operator and images on a offline Kubernetes cluster.

#### How to use it ?

- Fill a file called `resources.txt` with Punch Images versions that you want to deploy.
- Use the script to download, tag and tar images
- Tranferst tar images on your offline platform (Master Node)


### Punch Images Loader
This script can be used to load Punch images on your private registry.

#### How to use it ?
- On a Kubernetes Master run this script and use option to point on a folder that contains tar images

[More info here](https://punch-1.gitbook.io/punch-doc/deployment/scenarios/on-premise)