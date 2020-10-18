#!/bin/sh

apt-get install nginx -y -q

html_file='/var/www/html/index.nginx-debian.html'
sed -i '/<body>/,/<\/body>/{//!d}' $html_file
sed -i '/<body>/a <h1>OpsSchool rules!<\/h1>' $html_file