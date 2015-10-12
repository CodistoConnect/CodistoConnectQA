#!/bin/bash
sandringham -pluginbuild $HOME/approot/CodistoConnectQA/tasks/plugin/plugin.sh \"{BRANCH} {STASHPOP} {SHA1} {RESELLERKEY} {GITHUBTOKEN} {TEST}\" -listen 127.0.0.1 6971 -children 1 -service
