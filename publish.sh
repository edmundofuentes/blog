#!/bin/bash

echo "## Sculpin Generate"
vendor/bin/sculpin generate --env=prod
if [ $? -ne 0 ]; then echo "Could not generate the site"; exit 1; fi

echo "## Netlify Deploy"
# push it to netlify using the newer netlifyctl tool
netlifyctl deploy -P output_prod
