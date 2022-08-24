BRANCH_NAME=$1
MESSAGE=$2

git checkout -b "$BRANCH_NAME"
git add -A
git commit -m "$MESSAGE"
git push origin "$BRANCH_NAME":"$BRANCH_NAME"
