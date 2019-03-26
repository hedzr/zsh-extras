

# ----------------------------------------------


function if_nix () {
    case "$OSTYPE" in
        *linux*|*hurd*|*msys*|*cygwin*|*sua*|*interix*) sys="gnu";;
        *bsd*|*darwin*) sys="bsd";;
        *sunos*|*solaris*|*indiana*|*illumos*|*smartos*) sys="sun";;
    esac
    [[ "${sys}" == "$1" ]];
}
function if_mac () { [[ $OSTYPE == *darwin* ]]; }
function if_ubuntu () {
  if [[ $OSTYPE == *linux* ]]; then
    [ -f /etc/os-release ] && grep -qi 'ubuntu' /etc/os-release
  else
    false
  fi
}
function if_vagrant () {
  [ -d /vagrant ];
}
function if_centos () {
  if [[ $OSTYPE == *linux* ]]; then
    if [ -f /etc/centos-release ]; then
      :
    else
      [ -f /etc/issue ] && grep -qPi '(centos|(Amazon Linux AMI))' /etc/issue
    fi
  else
    false
  fi
}
# for qcloud VPC
# /etc/machine-id, /etc/machine-info
# /etc/cloud, /var/lib/cloud, 
# /usr/local/qcloud
function if_qcloud () {
  [ -f /etc/qcloudzone ] # && grep -qPi '' /etc/qcloudzone
}
# partically ok，aliyun ubuntu 14.04
function if_aliyun () {
  [ -f /etc/motd ] && grep -qPi 'ali(yun|baba)' /etc/motd
}
# partically ok，aliyun ubuntu 14.04
function if_aliyun_vpc () {
  [ -f /etc/motd ] && grep -qPi 'ali(yun|baba)' /etc/motd  && {
    sudo grep -qi 'aliyun' /var/lib/cloud/instance/datasource && {
      sudo grep -q 'vpc-id' /var/lib/cloud/instance/obj.pkl
    }
  }
}
# only amzn-linux
function aws_region() {
  [ -d /etc/yum/vars ] && cat /etc/yum/vars/awsregion
}
# only amzn-linux
function aws_domain() {
  [ -d /etc/yum/vars ] && cat /etc/yum/vars/awsdomain
}
# function if_aws_cn_2() {
#   [ -d /var/lib/cloud ] && [ -d /var/lib/cloud/instance ]
#   # curl http://169.254.169.254/latest/meta-data/instance-id
# }
function if_aws_cn() {
  #[ $(aws_domain) == 'amazonaws.com.cn' ];
  [ -r /var/lib/cloud/instance/obj.pkl ] && grep -q 'amazonaws.com.cn' /var/lib/cloud/instance/obj.pkl
}
function if_cloud_init_heavy () {
  if_centos && {
    # [ -f /etc/issue ] && grep -qPi 'Amazon Linux AMI' /etc/issue
    yum list | grep cloud-init
    return
  }

  dpkg -l | grep cloud-init
}
function if_cloud_init () {
  [[ -d /var/lib/cloud && -d /var/lib/cloud/instance && -d /etc/cloud ]];
}
function if_aws () {
  if_cloud_init && { [ -r /var/lib/cloud/instance/obj.pkl ] && grep -q 'amazonaws.com' /var/lib/cloud/instance/obj.pkl; }
}
# non-cn
function if_aws_us () {
  if_aws && { [ -r /var/lib/cloud/instance/obj.pkl ] && grep -qP 'us-(north|south|west|east)' /var/lib/cloud/instance/obj.pkl; }
}
function if_aws_linux_ami () {
  [ -f /etc/motd ] && grep -q 'amazon-linux-ami' /etc/motd
}
function aws-curl() {
  # http://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-instance-metadata.html#instancedata-data-retrieval
  curl http://169.254.169.254/latest/meta-data/
  echo ""
  # ami-id
  # ami-launch-index
  # ami-manifest-path
  # block-device-mapping/
  # hostname
  # instance-action
  # instance-id
  # instance-type
  # local-hostname
  # local-ipv4
  # mac
  # metrics/
  # network/
  # placement/
  # profile
  # public-hostname
  # public-ipv4
  # public-keys/
  # reservation-id
  # security-groups
  # services/
}

function if_hosttype () {
    case "$HOSTTYPE" in
        *x86_64*) sys="x64"; ;;
        *)        sys="x86"; ;;
    esac
    [[ "${sys}" == "$1" ]];
}

function list_all_env_variables () { declare -xp; }
function list_all_variables () { declare -p; }

function env_check () {
  cat <<-EOC
  ############### Checks
          centos: $(if_centos && echo Y)
          ubuntu: $(if_ubuntu && echo Y)
             mac: $(if_mac && echo Y)
         vagrant: $(if_vagrant && echo Y)

          aliyun: $(if_aliyun && echo Y)
      aliyun vpc: $(if_aliyun_vpc && echo Y)
             aws: $(if_aws && echo Y)
          aws_cn: $(if_aws_cn && echo Y)
          aws_us: $(if_aws_us && echo Y)
   aws_linux_ami: $(if_aws_linux_ami && echo Y)
          qcloud: $(if_qcloud && echo Y)
EOC
}
env-check () { env_check; }

if_new_ops () { [ -f /usr/local/bin/hz-ops/.env ]; }


function ports () {
    local SUDO=
    if [ $# -eq 0 ]; then
        $SUDO lsof -Pni | egrep "LISTEN|UDP"
    else
        local p=''
        local i
        for i in $*; do
            if [ "$i" -eq "$i" 2>/dev/null ]; then
                p="$p -i :$i"
            else
                p="$p -i $i"
            fi
        done
        $SUDO lsof -Pn $p
    fi
}
#function ports () { open-ports $*; }

# ----------------------------------------------









alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'
alias ip-wan=wanip

zipf () { zip -r "$1".zip "$1" ; }          # zipf:         To create a ZIP archive of a folder
alias numFiles='echo $(ls -1 | wc -l)'      # numFiles:     Count of non-hidden files in current dir
alias make1mb='mkfile 1m ./1MB.dat'         # make1mb:      Creates a file of 1mb size (all zeros)
alias make5mb='mkfile 5m ./5MB.dat'         # make5mb:      Creates a file of 5mb size (all zeros)
alias make10mb='mkfile 10m ./10MB.dat'      # make10mb:     Creates a file of 10mb size (all zeros)




ssl() {
  if [ $# -eq 0 ]; then
    cat <<EOF
\`ssl\` sub-command usages:
  save <host> [port]              save as a .cer file
  save-pem <host> [port]          save as a .pem file
  verify <host> [port]
  print <host> [port]
  print-local-pem <.pem-file without suffix>
  print-local-cer <.cer-file without suffix>
  print-local <.cer/.der/.crt-file with suffix>

https://www.sslshopper.com/article-most-common-openssl-commands.html
echo insecure >> ~/.curlrc
curl --insecure ....

EOF
  else
    local cmd=$1; shift
    case $cmd in
      *)          ssl-$cmd $*; ;;
    esac
  fi
}

ssl-save () {
  local h=$1
  local p=${2:-443}
  # echo |\
  # openssl s_client -connect $h:$p 2>&1 |\
  # sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $h.crt
  # echo "'$h.crt' saved:"
  # cat $h.crt
  openssl s_client -connect $h:$p -showcerts  </dev/null 2>/dev/null|openssl x509 -outform PEM >$h.pem && \
  echo "'$h.pem' saved"
  openssl x509 -outform der -in $h.pem -out $h.crt
  echo "'$h.crt' saved (.cer = .crt = .der):"
  #cat $h.crt
}

ssl-save-pem () {
  local h=$1
  local p=${2:-443}
  openssl s_client -connect $h:$p -showcerts  </dev/null 2>/dev/null|openssl x509 -outform PEM >$h.pem && \
  echo "'$h.pem' saved"
  openssl x509 -outform der -in $h.pem -out $h.der
}

ssl-print () {
  local h=$1
  local p=${2:-443}
  openssl s_client -connect $h:$p -showcerts  </dev/null
  #echo "'$h.pem' saved"
}

ssl-print-local-pem () {
  local f=$1
  cat $f.pem |  openssl x509 -inform pem -noout -text
}

ssl-print-local-cer () {
  local f=$1
  cat $f.cer |  openssl x509 -inform der -noout -text
}

ssl-print-local () {
  local f=$1
  cat $f |  openssl x509 -inform der -noout -text
}

ssl-p12-to-pem () {
  openssl pkcs12 -in keyStore.pfx -out keyStore.pem -nodes
}

ssl-p12-build () {
  openssl pkcs12 -export -out certificate.pfx -inkey privateKey.key -in certificate.crt -certfile CACert.crt
}




# . /opt/test/docker-develop/my-gitlab/docker_functions
#[[ -f $HOME/.bashrc_docker ]] && source "$HOME/.bashrc_docker"
[[ -f $HOME/bin/.docker_functions ]] && source "$HOME/bin/.docker_functions"

############################################# MAC
is_darwin && {
	#[ -f $HOME/bin/.aliases.mac ] && source $HOME/bin/.aliases.mac
	
	#   spotlight: Search for a file using MacOS Spotlight's metadata
	#   -----------------------------------------------------------
    spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }

	#   ii:  display useful host related informaton
	#   -------------------------------------------------------------------
    ii() {
        echo -e "\nYou are logged on ${RED}$HOST"
        echo -e "\nAdditionnal information:$NC " ; uname -a
        echo -e "\n${RED}Users logged on:$NC " ; w -h
        echo -e "\n${RED}Current date :$NC " ; date
        echo -e "\n${RED}Machine stats :$NC " ; uptime
        echo -e "\n${RED}Current network location : $NC " ; scselect
        #echo -ne "\n${RED}Public facing IP Address : $RED$(myip)"
        #echo -ne "\n${RED}Local IP Address  : ${RED}$(mylocalip) / $(mylocalgw) / $(mylocalni)"
        #echo -e "\n${RED}DNS Configurations:$NC " ; mylocaldns
        echo
    }

	#   cleanupDS:  Recursively delete .DS_Store files
	#   -------------------------------------------------------------------
	    alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"

	#   finderShowHidden:   Show hidden files in Finder
	#   finderHideHidden:   Hide hidden files in Finder
	#   -------------------------------------------------------------------
	    alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
	    alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'

	#   cleanupLS:  Clean up LaunchServices to remove duplicates in the "Open With" menu
	#   -----------------------------------------------------------------------------------
	    alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

	#    screensaverDesktop: Run a screensaver on the Desktop
	#   -----------------------------------------------------------------------------------
	    alias screensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'

	# forbit autoupdate on homebrew installing
	export HOMEBREW_NO_AUTO_UPDATE=1
	# https://superuser.com/questions/975701/how-can-i-remove-outdated-installed-versions-of-homebrew-packages
	alias brewski='brew update && brew upgrade && brew cleanup; brew doctor'
}
############################################# MAC END




# stree .
# open the current folder to SourceTree
alias stree='open -a SourceTree'

alias find_build_and_rm='find . -type d -iname "build" -exec rm -rf {} \;'
alias find_idea_build_and_rm='find . -type d -iname "build" -exec rm -rf {} \; ; find . -type d -iname ".gradle" -exec rm -rf {} \; ; find . -type f -iname "*.iml" -delete'

# Mongodb
# nano /usr/local/etc/mongod.conf
start-mongodb () { mongod; }
start-mongodb-strong () { sudo chown -R `id -u` /data/db; mongod; }
start-mongodb-at () { mongod --dbpath $*; }

# test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

[ -r $HOME/bin/dex2jar-2.0/d2j-dex2jar.sh ] && alias dex2jar='sh $HOME/bin/dex2jar-2.0/d2j-dex2jar.sh'
#alias sdkman-load='export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"'
#echo -e "\nUsing 'sdkman-load' to enable 'sdk' command, \nif you wanna work in Grails, Gradle, Maven, Spring Boot, Scala, Kotlin, Griffon, Glide, Gaiden, Ant.\nFor more information, see also:\nhttp://get.sdkman.io/ && http://sdkman.io/ && http://api.sdkman.io/\n"
[ -r "$HOME/.sdkman/bin/sdkman-init.sh" ] && export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"
# echo -e "\nsdkman loaded. Tools ready: Grails, Gradle, Maven, Spring Boot,...\n"

urldecode () {  perl -MURI::Escape -e 'print uri_unescape($ARGV[0])' $*; }
# echo -e "gbk2utf8: convert gbk text to utf8.\nurldecode: decode the escaped url.\n"

# tabtab source for yo package
# uninstall by removing these lines or running `tabtab uninstall yo`
[ -f /usr/local/lib/node_modules/yo/node_modules/tabtab/.completions/yo.bash ] && . /usr/local/lib/node_modules/yo/node_modules/tabtab/.completions/yo.bash

# echo -e "yo autocompletions installed. "
# echo -e "GOPATH = $GOPATH, GOROOT = $GOROOT"
export PATH=$GOROOT/bin:$PATH
export ETCDCTL_API=3

# added by travis gem
[ -f /Users/hz/.travis/travis.sh ] && source /Users/hz/.travis/travis.sh

# vagrant shortcuts
alias vup='vagrant up && vagrant ssh'
alias vdup='vagrant destroy -f && vup'

# NVM
if [ -s ~/.nvm/nvm.sh ]; then
	NVM_DIR=~/.nvm
	source ~/.nvm/nvm.sh
	#nvm use stable
	#nvm alias default stable
	#nvm alias default iojs
fi


# enable ssh-agent and remember my key, so that ssh a remote server via jumper-machine
is_darwin && ssh-add -K ~/.ssh/id_rsa || ssh-add ~/.ssh/id_rsa
alias ssh='ssh -A'














