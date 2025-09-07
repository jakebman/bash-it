# shellcheck shell=bash
cite about-plugin
about-plugin 'pass all aws commands through `aws autologin-and-then`, an aws alias which logs you in automatically'


alias aws='BROWSER="${BASH_IT_AWS_BROWSER-${AWS_BROWSER-$BROWSER}}" aws autologin-and-then'
