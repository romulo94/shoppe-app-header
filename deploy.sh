curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o ./jq
chmod a+x ./jq

# GET VERSION
VERSION=$(node --eval="process.stdout.write(require('./package.json').version)")

# GET importmap from S3
aws s3 cp s3://mfe-shoppe/config/import-map.json import-map.json

# UPDATE URL PATH
NEW_URL=/config/mfe/app-header/$VERSION/shoppe-app-header.js

# MODIFY import-map.json
cat ./import-map.json | ./jq --arg NEW_URL "$NEW_URL" '.imports["@shoppe/app-header"] = $NEW_URL' > new.importmap.json

# UPLOAD new importmap
aws s3 cp new.importmap.json s3://mfe-shoppe/config/import-map.json

# INVALIDATION cache
aws cloudfront create-invalidation --distribution-id E2CSYO6LJ44WFR --paths '/config/import-map.json'
