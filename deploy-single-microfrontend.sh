curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o ./jq
chmod a+x ./jq

# Download the import map
aws s3 cp s3://bucket-name/live.importmap live.importmap || echo '{"imports": {}}' > live.importmap

echo "Import Map before deployment:"
cat ./live.importmap

NEW_URL=https://shoppe.cactoit.com/config/mfe/@shoppe/app-header/$VERSION/shoppe-app-header.js

# Modify the import map
cat ./live.importmap | ./jq --arg NEW_URL "$NEW_URL" '.imports["@fc/styleguide"] = $NEW_URL' > new.importmap

echo "Import Map after deployment"
cat new.importmap

# Upload
aws s3 cp --content-type application/importmap+json --cache-control 'public, must-revalidate, max-age=10;' live.importmap s3://bucket-name/live.importmap