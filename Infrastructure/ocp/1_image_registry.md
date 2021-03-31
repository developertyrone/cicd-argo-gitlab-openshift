

oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-pv
spec:
  capacity:
    storage: 500Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /opt/nfs/ocp-registry
    server: manage.ocp.hk.sunlife
  claimRef:
    name: image-registry-pvc
    namespace: openshift-image-registry
EOF


cat <<EOF | oc create -n openshift-image-registry -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: image-registry-pvc
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 500Gi
EOF


oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed"}}'
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"pvc":{"claim": "image-registry-pvc"}}}}'