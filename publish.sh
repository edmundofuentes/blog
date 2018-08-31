#!/bin/bash

echo "## Sculpin Generate"
vendor/bin/sculpin generate --env=prod
if [ $? -ne 0 ]; then echo "Could not generate the site"; exit 1; fi

## Rename .html.twig files to .html only
echo "FIX: Cleaning up the filenames"
cd output_prod
find . -name '*.html.twig' -exec sh -c 'mv "$0" "${0%.html.twig}.html"' {} \;
cd ..

echo "## Netlify Deploy"
# push it to netlify using the newer netlifyctl tool
netlifyctl deploy -P output_prod
