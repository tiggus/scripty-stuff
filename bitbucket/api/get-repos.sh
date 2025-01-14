export PAT=pat
export WORKSPACE=workspace
export PROJECT=project

echo "--- get repos ---"
curl -s --request GET \
  --url "https://api.bitbucket.org/2.0/repositories/$WORKSPACE?q=project.key=\"$PROJECT\"&pagelen=100&?limit=1000" \
  --header "Authorization: Bearer $PAT" \
  --header "Accept: application/json" -o bitbucket.json
cat bitbucket.json | jq -r '.values[] | "\(.name),\(.created_on),\(.updated_on)"'
