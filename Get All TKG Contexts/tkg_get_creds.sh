arr=( $(tkg get clusters -o json | jq -r '.[].name' ) )
for i in "${arr[@]}"
do
  echo "Getting Credentials for $i"
  tkg get credentials $i
done