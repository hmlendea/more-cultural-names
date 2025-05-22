#!/bin/bash

function get_variable() {
    local VAR_NAME="${1}"
    echo "${!VAR_NAME}"
}