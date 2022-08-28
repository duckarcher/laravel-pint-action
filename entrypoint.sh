#!/bin/bash
set -e

PINT_OUTPUT=$(/tmp/vendor/bin/pint $1)

if [[ "$2" == "true" ]]; then
    echo -e "::set-output name=pint_output::$PINT_OUTPUT"
else
    echo -e "$PINT_OUTPUT"
fi
