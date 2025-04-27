#!/bin/bash
cd ~/electrumx

# Clean bad env first
unset HOST

# Export config variables
export $(grep -v '^#' electrumx.conf | xargs)

# Launch server
./electrumx_server
