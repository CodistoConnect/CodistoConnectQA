#!/bin/bash
sandringham -phplinter ${HOME}/approot/CodistoConnectQA/tasks/linting/php/bot_php_compatibility_check.sh \"{PHPVERSION}\" \
				-githelper ${HOME}/approot/CodistoConnectQA/tasks/linting/githelper.sh \"{STASHPOP} {SHA1}\" \
				-listen 127.0.0.1 6972 -children 1 -service
