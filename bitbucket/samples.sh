export SLUG=slug
export OUTFILE=haspipelines
echo "--- configuring system ---"
rm -rf json
mkdir json
rm -rf haspipelines

echo "--- get repos ---"
curl -s --request GET \
  --url "https://api.bitbucket.org/2.0/repositories/$WORKSPACE?pagelen=100&page=1" \
  --header "Authorization: Bearer $PAT"
  --header "Accept: application/json" -o ./json/bitbucket.json
  
  echo "--- exporting repo uri ---"
  cat ./json/bitbucket.json | jq '.values|.[]|.links.self.href' > ./json/bitbucket-href.json
  echo "--- query pipelines ---"
  while read p; do
    URI="${p//\"}"
    SIZE=$(curl -s --request GET --url "$URI/pipelines?pagelen=100&page=1" --header "Authorization: Bearer $PAT" --header 'Accept: application/json' | jq '.size')
    echo $URI :: $SIZE\n    if (( $SIZE > 0 )); then
    echo $URI :: $SIZE >> $OUTFILE
  fi
  done <./json/bitbucket-href.json\nrm -rf json
  echo "--- results ---"    
  if [ -f $OUTFILE ]; then
     cat $OUTFILE
       rm -rf $OUTFILE\nelse
          echo "no pipes"
          fi
