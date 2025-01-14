export TIME=$(date +%Y-%m-%d-%H%M%S)
echo "name,scm,size,pulls" > allrepos-$TIME.csv

echo "--- get repos ---"
curl -s --request GET \
  --url "https://api.bitbucket.org/2.0/repositories/$WORKSPACE?q=project.key=\"$PROJECT\"&pagelen=100&?limit=1000" \
  --header "Authorization: Bearer $PAT" \
  --header "Accept: application/json" |  jq '.values[] | "\(.name),\(.scm),\(.size),\(.links.pullrequests.href)"' > repos.json

echo "--- query pulls ---"
while read p; do
  INFO="${p//\"}"
  declare url=$( echo $INFO| cut -d "," -f 4)
  PULLS=$(curl -s --request GET --url "$url?state=ALL&?pagelen=100" --header "Authorization: Bearer $PAT" --header 'Accept: application/json' | jq '.size')  
  echo $INFO,$PULLS
  echo $(echo $INFO | cut -d "," -f 1,2,3,5),$PULLS >> allrepos-$TIME.csv
done <./repos.json

open allrepos-$TIME.csv -a "Microsoft Excel"
