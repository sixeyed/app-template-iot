Copy `iotkit-library.yaml` to somewhere useful:

```
cp iotkit-library.yaml /tmp
```

Update your App Template config in `~/.docker/application-template/preferences.yaml` include the new library. 

This example includes the local demo libraries and the main Docker library:

```
apiVersion: v1alpha1
disableFeedback: false
kind: Preferences
repositories:
- name: iot-starter-kit
  url: file:///tmp/iotkit-library.yaml
- name: azure-demo
  url: file:///tmp/library.yaml
- name: library
  url: https://docker-application-template.s3.amazonaws.com/production/v0.1.1/library.yaml
```