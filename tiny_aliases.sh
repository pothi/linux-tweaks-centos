
### custom aliases by pothi @ tinywp.com

# Aliases for `ls`

alias ls='ls --color=never --group-directories-first --classify'
alias l='ls --color=never --group-directories-first --classify'
# use the following if --color=auto did not work
# alias l='ls --color=always --group-directories-first --classify'
# if OS sets up colors and to get rid of colors, use --color=never

alias la='l --almost-all'
alias ld='l -ld'
alias ll='l -l' 
alias lh='l -lh'

alias lal='l -l --almost-all'
alias lla='l -l --almost-all'
alias llh='l -lh'
alias lah='l -h --almost-all'
alias lalh='l -lh --almost-all'
alias llah='l -lh --almost-all'

# alias wl='wc -l'
alias fm='free -m'
alias c='cd'
alias ping='ping -c 1'

# Sed
alias sed='/bin/sed --follow-symlinks'

### Curl aliases ###
### Ref - http://curl.haxx.se/docs/manpage.html
alias curli='curl -I'
alias curlih='curl -I -H "Accept-Encoding:gzip,deflate"'
alias curld='curl -H "Accept-Encoding:gzip,deflate" -s -D- -o /dev/null'

# Explanation for the above
# curli='curl --head' # strange character to replace --head
# curlih='curl -I --header "Accept-Encoding:gzip,deflate"'
# curld='curl -H "Accept-Encoding:gzip,deflate" --silent --dump-header - --output /dev/null'

# Dig aliases
alias digs='dig +short'
alias digc='dig +short CNAME'
alias digns='dig +short NS'
alias digmx='dig +short MX'

### end of custom aliases by pothi ###

