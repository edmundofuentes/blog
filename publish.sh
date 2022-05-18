#!/bin/bash

echo "## Sculpin Generate"
vendor/bin/sculpin generate --env=prod
if [ $? -ne 0 ]; then echo "Could not generate the site"; exit 1; fi

# TODO: Sculpin is broken and prints out wrong "page" URLs
## Rename .html.twig files to .html only
#echo "FIX: Cleaning up the filenames"
#cd output_prod
#find . -name '*.html.twig' -exec sh -c 'mv "$0" "${0%.html.twig}.html"' {} \;
#cd ..

echo "## Netlify Deploy"
# push it to netlify using the newer netlify-cli tool
netlify deploy --prod --dir output_prod --site edmundofuentes
