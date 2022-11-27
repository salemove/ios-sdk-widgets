#!/bin/bash

if [ "$SHOULD_LINT_ON_PRECOMMIT" != 1 ]; then
    exit 0
fi

# Checks and sets the appropriate SwiftLint path for M1 or Intel CPU
if [[ $(uname -m) == 'arm64' ]]; then
    SWIFT_LINT=/opt/homebrew/bin/swiftlint
else
    SWIFT_LINT=/usr/local/bin/swiftlint
fi

# Checks if SwiftLint is installed
if ! [[ -e "${SWIFT_LINT}" ]]; then
    echo -e "\033[1;31mSwiftLint with path ${SWIFT_LINT} is not installed.\033[0m"
    exit 1
fi

# Gets paths for changed files
unstaged_files=$(git diff --diff-filter=d --name-only | grep ".swift$")
staged_files=$(git diff --diff-filter=d --name-only --cached | grep "\.swift$")

count=0

# Checks if the unstaged file exists and increments the count value
for file_path in $unstaged_files; do
    if [[ -f "$file_path" ]]; then
        export SCRIPT_INPUT_FILE_$count=$file_path
        count=$((count + 1))
    fi
done

# Checks if the staged file exists and increments the count value
for file_path in $staged_files; do
    if [[ -f "$file_path" ]]; then
        export SCRIPT_INPUT_FILE_$count=$file_path
        count=$((count + 1))
    fi
done

# Checks if the count is not equal to 0
# If it's 0, that means there's no file to lint and script exits with success status
if [ "$count" -ne 0 ]; then
    export SCRIPT_INPUT_FILE_COUNT=$count

    # Checks if passed params is "commit"
    # "commit" indicates that the script is being run by the pre-commit hook
    if [[ $1 = "commit" ]]; then

        # Gets the result of linting of changed files
        RESULT=$($SWIFT_LINT lint --use-script-input-files --use-alternative-excluding --config .swiftlint.yml)

        # Checks the result is empty
        if [ "$RESULT" == '' ]; then
            echo -e "\033[1;32mSwiftLint finished successfully.\033[0m"
            exit 0
        else
            echo -e "\033[1;33m$RESULT\033[0m"
            echo -e "\033[1;31mFix SwiftLint warnings before commit!\033[0m"
            exit 1
        fi
    else
        $SWIFT_LINT lint --use-script-input-files --force-exclude --use-alternative-excluding
    fi
else
    echo -e "\033[1;32mNo files to lint.\033[0m"
    exit 0
fi
