#!/bin/bash

# escape all double quotes with double quotes in a whole line (for example " will be "", how it described in rfc4180)
cat - | sed 's,","",g'
