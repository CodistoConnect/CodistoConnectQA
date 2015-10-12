#!/bin/bash
env BONDI_APPROOT=$HOME/approot/CodistoConnectQA BONDI_STRICT=0 bondi -script tasks/integration-tests/tests.esp
