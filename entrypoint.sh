#!/bin/bash
set -e

echo "before all"

ISSUE_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
GITHUB_URL="https://api.github.com"
BRANCH=${GITHUB_HEAD_REF#refs/heads/}

if [[ ! -z "$GITHUB_CUSTOM_URL" ]]; then
    GITHUB_URL=$GITHUB_CUSTOM_URL
fi

echo "before pint command"

PINT_OUTPUT=$(./vendor/bin/pint $1)

echo "after pint command"

echo -e "$PINT_OUTPUT"

if [[ "$2" == "true" ]]; then
    # auto commit
    COMMENT="# Formatted code for PR#$ISSUE_NUMBER"
    AUTHOR="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>"

    if [[ "$1" == *"--test"* ]]; then
        echo "--test found in args, skipping auto commit."
    else
        git fetch --depth=1
        git checkout "$BRANCH" --
        git config user.name 'github-actions[bot]'
        git config user.email 'github-actions[bot]@users.noreply.github.com'

        if [[ ! -n "$(git status -s --)" ]]; then
            echo "no changes found, skipping auto commit."
        else
            git add .
            git commit -m 'Fixed styling' --author "$AUTHOR"
            
            HASH=$(git rev-parse HEAD)
            echo -e "$COMMENT\n$HASH" >> .git-blame-ignore-revs
            
            git add .git-blame-ignore-revs
            git commit -m 'Updated .git-blame-ignore-revs' --author "$AUTHOR"
            git push -u origin "$BRANCH"
        fi
    fi
fi

if [[ "$3" == "true" ]]; then
    # pr message
    JSON=$(jq --null-input --arg body "$PINT_OUTPUT" '{"body": "Laravel Pint Output:\n```\n\($body)\n```"}')

    curl -X POST "$GITHUB_URL/repos/$GITHUB_REPOSITORY/issues/$ISSUE_NUMBER/comments" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        -d "$JSON"
fi
