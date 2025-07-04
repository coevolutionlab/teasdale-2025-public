#!/bin/bash

rsync -rhivtPL --chown root:www-data "$(dirname "$(readlink -f "$0")")/igv/"  root@d6dataviz:/data/www/dl20/hodgepodge-output/ "${@}"
