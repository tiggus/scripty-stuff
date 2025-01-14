export APIREGION="eu-west-2"
export APIS=$(aws apigateway get-rest-apis --region $APIREGION --output json | jq '.items[] | "\(.id):\(.name)"' )
export PAGER=""
export TIME=$(date +%Y-%m-%d-%H%M%S)
export DIR=$TIME/json
export STAGE="prod"
mkdir -p $DIR

for api in $(echo "${APIS}")
do
    declare id=$(echo $api | cut -d: -f1 | sed 's/"//g') 
    declare apin=$(echo $api | cut -d: -f2 | sed 's/"//g')
    echo "---------------------------------"
    echo $apin : $id
    declare allstages=$(aws apigateway get-stages --rest-api-id $id --region $APIREGION --output json | jq -r '.item[].stageName')
    declare -i i=0
    echo $allstages
    aws apigateway get-export --parameters extensions='apigateway' --rest-api-id $id --stage-name $STAGE --export-type swagger ./$DIR/$apin-$id.json --region $APIREGION
done
