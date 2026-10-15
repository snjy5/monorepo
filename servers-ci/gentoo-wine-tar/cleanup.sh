#!/usr/bin/env bash

# Make Sure The Environment Is Non-Interactive
export HOME="/home/runner"
export DEBIAN_FRONTEND="noninteractive"

mount -o remount,rw /

for i in $(docker ps -q -a); do docker rmi -f $i; done

apt update -y

apt autoremove --allow-remove-essential -y \
  clang-* clang-format-* libclang-common-*-dev libclang-cpp* libclang1-* \
  liblldb-* lld-* lldb-* llvm-*-dev llvm-*-runtime llvm-*-tools llvm-* \
  adoptopenjdk-* openjdk* ant* \
  *-icon-theme plymouth *-theme* fonts-* gsfonts gtk-update-icon-cache \
  google-cloud-sdk \
  apache2* nginx msodbcsql* mssql-tools mysql* libmysqlclient* unixodbc-dev postgresql* libpq-dev odbcinst* mongodb-* \
  apport* popularity-contest \
  aspnetcore-* dotnet* sphinxsearch \
  azure-cli session-manager-plugin \
  brltty byobu htop \
  buildah hhvm kubectl packagekit* podman podman-plugins skopeo \
  chromium-browser firebird* firefox google-chrome* xvfb \
  esl-erlang ghc-* groff-base rake r-base* r-cran-* r-doc-* r-recommended ruby* swig* \
  gfortran* \
  gh subversion mercurial mercurial-common \
  info install-info landscape-common \
  libpython2* imagemagick* libmagic* vim vim-* \
  man-db manpages \
  mono-* mono* libmono-* \
  nuget packages-microsoft-prod snapd yarn \
  php-* php5* php7* php8* snmp


curl -qsL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh | bash
curl -qsL https://raw.githubusercontent.com/BryanDollery/remove-snap/main/remove-snap.sh | bash

rm -rf -- ./uninstall-brew.sh /home/linuxbrew

{
npm list -g --depth=0. | awk -F ' ' '{print $2}' | awk -F '@[0-9]' '{print $1}' | grep -v "^n$" |  xargs npm remove -g
yes |  n uninstall
}

parallel --use-cpus-instead-of-cores  rm -rf {} ::: /usr/local/lib/node_modules ::: /usr/local/bin ::: /usr/local/bin/vercel
parallel --use-cpus-instead-of-cores  rm -rf -- {} ::: /opt/hostedtoolcache ::: /usr/local/lib/android ::: /usr/share/gradle* /usr/bin/gradle /usr/share/apache-maven* /usr/bin/mvn
parallel --use-cpus-instead-of-cores  rm -rf -- {} ::: /usr/local/share/vcpkg /usr/local/bin/vcpkg ::: /usr/share/miniconda ::: /usr/bin/conda /usr/local/lib/lein /usr/local/bin/lein /usr/local/bin/pulumi*
parallel --use-cpus-instead-of-cores  rm -rf -- {} ::: /usr/share/java/selenium-server-standalone.jar /usr/local/share/phantomjs* /usr/local/bin/phantomjs /usr/local/share/chrome_driver /usr/bin/chromedriver /usr/local/share/gecko_driver /usr/bin/geckodriver ::: /etc/php /usr/bin/composer /usr/local/bin/phpunit ::: /var/lib/mysql /etc/mysql /usr/local/bin/sqlcmd /usr/local/bin/bcp /usr/local/bin/session-manager-plugin
parallel --use-cpus-instead-of-cores  rm -rf -- {} ::: /usr/local/julia* /usr/bin/julia ::: /usr/share/rust /home/runner/.cargo /home/runner/.rustup /home/runner/.ghcup ::: /usr/local/bin/rake /usr/local/bin/rdoc /usr/local/bin/ri /usr/local/bin/racc /usr/local/bin/rougify ::: /usr/local/bin/bundle /usr/local/bin/bundler /var/lib/gems ::: /usr/share/swift /usr/local/bin/swift /usr/local/bin/swiftc /usr/bin/ghc /usr/local/.ghcup /usr/local/bin/stack /usr/local/bin/rebar3 /usr/share/sbt /usr/bin/sbt /usr/bin/go /usr/bin/gofmt
parallel --use-cpus-instead-of-cores  rm -rf -- {} ::: /usr/local/bin/aws /usr/local/bin/aws_completer /usr/local/aws-cli /usr/local/aws /usr/local/bin/aliyun /usr/share/az_* /opt/az /usr/bin/az /usr/local/bin/azcopy* /usr/bin/azcopy /usr/lib/azcopy /usr/local/bin/oc /usr/local/bin/oras ::: /usr/local/bin/packer /usr/local/bin/terraform /usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/kind /usr/local/bin/kustomize /usr/local/bin/minikube /usr/libexec/catatonit/catatonit
parallel --use-cpus-instead-of-cores  rm -rf -- {} ::: /usr/share/dotnet ::: /usr/local/graalvm ::: /usr/share/man ::: /var/lib/apt/lists/* /var/cache/apt/archives/*
parallel --use-cpus-instead-of-cores  rm -rf -- {} :::  /etc/mysql /etc/php /usr/local/share/chrome_driver $HOME/.cache /var/cache/* /usr/bin/geckodriver /usr/local/share/boost /opt/ /usr/src $AGENT_TOOLSDIRECTORY /home/runneradmin /root/* /snap/* $(echo /boot/* | grep -vo efi)

sed -i -e '/^PATH=/d;/hostedtoolcache/d;/^AZURE/d;/^SWIFT/d;/^DOTNET/d;/DRIVER/d;/^CHROME/d;/HASKELL/d;/^JAVA/d;/^SELENIUM/d;/^GRAALVM/d;/^ANT/d;/^GRADLE/d;/^LEIN/d;/^CONDA/d;/^VCPKG/d;/^ANDROID/d;/^PIPX/d;/^HOMEBREW/d;' /etc/environment
sed -i '1i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' /etc/environment
sed -i '/HOME\/\.local\/bin/d' /home/runner/.bashrc
. /home/runner/.bashrc
