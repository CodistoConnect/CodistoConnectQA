#!/bin/bash
sandringham -phplinter $HOME/approot/CodistoConnectQA/tasks/linting/bot_php_compatibility_check.sh \"{PHPVERSION} {STASHPOP} {SHA1}\" -listen 127.0.0.1 6972 -children 1 -service


