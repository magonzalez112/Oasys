#!/bin/bash

/usr/bin/stty 9600 -F /dev/ttyS0 raw -echo
cat /dev/ttyS0
