curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o ./jq
chmod a+x ./jq

# Get VERSION
VERSION=$(node --eval="process.stdout.write(require('./package.json').version)")

# Download the import map
aws s3 cp s3://mfe-shoppe/config/import-map.json import-map.json || echo '{"imports": {}}' > import-map.json

# Upload build
aws s3 cp dist s3://mfe-shoppe/config/mfe/app-header/$VERSION --recursive

echo "Import Map before deployment:"
cat ./import-map.json

NEW_URL=https://shoppe.cactoit.com/config/mfe/app-header/$VERSION/shoppe-app-header.js

# Modify the import map
cat ./import-map.json | ./jq --arg NEW_URL "$NEW_URL" '.imports["@shoppe/app-header"] = $NEW_URL' > new.importmap.json

echo "Import Map after deployment"
cat new.importmap.json

# Upload
aws s3 cp --content-type application/importmap+json new.importmap.json s3://mfe-shoppe/config/import-map.json

# Invalidate cache
aws cloudfront create-invalidation --distribution-id E2CSYO6LJ44WFR --paths '/*'