#!/bin/bash

# Simple deployment script for the GitBook (Docsify based)

# 1. Preview locally (Optional)
if [[ "$1" == "--preview" ]]; then
    echo "Checking for docsify-cli..."
    if ! command -v docsify &> /dev/null
    then
        echo "docsify-cli not found. Installing locally..."
        npm install docsify-cli -g
    fi

    echo "Starting local preview server..."
    echo "Open http://localhost:3000 to view your GitBook"

    # Create a local index.html for docsify if it doesn't exist
    if [ ! -f index.html ]; then
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Audiophile Component Guide</title>
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
  <meta name="description" content="A comprehensive guide for audiophile amplifier components.">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0">
  <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/vue.css">
</head>
<body>
  <div id="app"></div>
  <script>
    window.\$docsify = {
      name: 'Audiophile Guide',
      repo: '',
      loadSidebar: 'SUMMARY.md',
      subMaxLevel: 2
    }
  </script>
  <!-- Docsify v4 -->
  <script src="//cdn.jsdelivr.net/npm/docsify@4"></script>
</body>
</html>
EOF
    fi

    docsify serve .
    exit 0
fi

# 2. Deploy to GitHub
echo "Deploying changes to GitHub..."

# Add all changes
git add .

# Set commit message
COMMIT_MSG=${1:-"Update components and GitBook structure"}

# Commit changes
git commit -m "$COMMIT_MSG"

# Push to origin
echo "Pushing to origin..."
git push origin $(git rev-parse --abbrev-ref HEAD)

echo "Done! GitHub Pages will update automatically if configured."
