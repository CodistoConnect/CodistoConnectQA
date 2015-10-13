#!/bin/bash
env BONDI_APPROOT=$HOME/approot/CodistoConnectQA CLI=1  BONDI_STRICT=0 bondi -script tasks/integration-tests/tests.esp
