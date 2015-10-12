#!/bin/bash
env BONDI_APPROOT=$HOME/approot BONDI_STRICT=0 bondi -script CodistoConnectQA/tasks/integration-tests/tests.esp
