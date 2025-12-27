#!/bin/bash

# Deployment script for the Audiophile Component Guide
set -e

# 1. Preview locally
if [[ "$1" == "--preview" ]]; then
    echo "Checking for docsify-cli..."
    if ! command -v docsify &> /dev/null; then
        echo "docsify-cli not found. Installing locally..."
        npm install docsify-cli -g
    fi

    echo "Starting local preview server..."
    echo "Open http://localhost:3000 to view your GitBook"

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
      repo: 'https://github.com/techworldthink/audiophile',
      loadSidebar: 'SUMMARY.md',
      subMaxLevel: 2
    }
  </script>
  <script src="//cdn.jsdelivr.net/npm/docsify@4"></script>
</body>
</html>
EOF
    fi

    docsify serve .
    exit 0
fi

# 2. Deploy to GitHub (Main Branch)
echo "Staging changes..."
git add .

# Set commit message
COMMIT_MSG=${1:-"Update components and GitBook structure"}
echo "Committing changes with message: $COMMIT_MSG"
git commit -m "$COMMIT_MSG" || echo "No changes to commit on $(git rev-parse --abbrev-ref HEAD)"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Pushing to origin $CURRENT_BRANCH..."
git push origin "$CURRENT_BRANCH"

# 3. Deploy to GitHub Pages (gh-pages branch)
read -p "Deploy to GitHub Pages (gh-pages branch)? (y/n): " deploy_pages
if [ "$deploy_pages" = "y" ]; then
    echo "Deploying to GitHub Pages..."
    
    # Check if gh-pages branch exists locally, if not create from main
    if git rev-parse --verify gh-pages >/dev/null 2>&1; then
        git checkout gh-pages
    else
        git checkout -b gh-pages
    fi
    
    # Merge main into gh-pages (or just overwrite)
    git merge main --no-edit || (echo "Conflict detected, overwriting gh-pages with main" && git checkout main -- . && git commit -m "Overwrite gh-pages with main content")
    
    # Push to gh-pages
    echo "Pushing to origin gh-pages..."
    git push origin gh-pages --force
    
    # Switch back to original branch
    git checkout "$CURRENT_BRANCH"
    
    echo "Successfully deployed to GitHub Pages"
    echo "Your guide will be available at: https://techworldthink.github.io/audiophile/"
fi

echo "Deployment process completed"
