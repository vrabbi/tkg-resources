kubectl config unset users.$1-admin
kubectl config unset contexts.$1-admin@$1
kubectl config unset clusters.$1