RELVERSION=2.4.46
ROOTPATH=$PWD
WORKPATH=${ROOTPATH}/apache${RELVERSION}
PACKPATH=${ROOTPATH}/packages
APACHEPATH=${PACKPATH}/httpd
OPENSSLPATH=${PACKPATH}/openssl
PCREPATH=${PACKPATH}/PCRE
APRPATH=/usr/local/apr
SSLLIBPATH=$APACHEPATH/lib/openssl


OSDIST=UNKNOWN
INSTALLER=
SUDO=
NOSTOUT=" >/dev/null"
CORECPATCH=$ROOTPATH/core.c.patch

PRCEURL="https://sourceforge.net/projects/pcre/files/pcre/8.44/pcre-8.44.tar.gz"
OPENSSLURL="https://www.openssl.org/source/openssl-1.1.1h.tar.gz"
APRURL="https://apache.cs.utah.edu//apr/apr-1.7.0.tar.gz"
APRUTILURL="wget https://mirrors.ocf.berkeley.edu/apache//apr/apr-util-1.6.1.tar.gz"
APACHEBASEURL="https://downloads.apache.org//httpd/httpd-"
MODJKURL="https://downloads.apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz"

function configure_envs {

  if [ $(grep -i centos /etc/os-release | wc -l) -ne 0  ]; then
    OSDIST=centos
    which yum > /dev/null && INSTALLER=yum
    which dnf > /dev/null && INSTALLER=dnf
  elif [ $(grep -i suse /etc/os-release | wc -l) -ne 0  ]; then
    OSDIST=suse
    which zypper > /dev/null && INSTALLER=zypper
  else
    echo No package installer found!
    return 1
  fi

}

function get_tools {
  local PACKS
  if [ "$EUID" -ne "0" ]; then
      SUDO="sudo "
  fi

  case "$OSDIST" in
    centos)
      PACKS="expat-devel perl-IPC-Run zlib-devel "
      ;;

    suse)
      ;;
   *)
      echo "Unknown OS distibution " + $OSDIST
      return 1
      ;;
  esac
  $SUDO $INSTALLER update -y && $SUDO $INSTALLER install -y $PACKS
}

function create_paths {
  local ALLPATHS="$WORKPATH $APACHEPATH $OPENSSLPATH $PCREPATH $SSLLIBPATH "

  if [ -z $1 ]; then
    for PP in $ALLPATHS; do
      [ -d $PP ] && echo $PP " exists!" && return 1
    done
    mkdir -p $ALLPATHS || ( echo "failed to create paths" && popd && return 1)
  else
    mkdir -p $ALLPATHS $NOSTOUT
  fi
}

function install_apr {
  pushd . $NOSTOUT
  cd /tmp/

  # install apr
  local APR=apr.tar.gz

  echo "Installing apr package..."
  wget $APRURL -O $APR && \
  tar -xzf $APR && cd apr-*

  ./configure && make && $SUDO make install || (echo "failed to compile apr " && popd && return 1)
  [ ! -d $APRPATH ] && echo "can't find apr after installing apr from source code" && popd && return 1
  echo "Installed apr package"
  rm -rf $APR apr-* $NOSTOUT

  # install apr-util
  local APRUTIL=aprutil.tar.gz

  echo "Installing apr-util package..."
  wget wget $APRUTILURL -O $APRUTIL && \
  tar -xzf $APRUTIL && cd apr-util*

  ./configure --with-apr=$APRPATH && make && $SUDO make install || (echo "failed to compile apr util" && popd && return 1)
  echo "Installed apr-util package"
  rm -rf $APRUTIL apr-util* $NOSTOUT

  popd $NOSTOUT
}

function install_pcre {
  pushd . $NOSTOUT
  cd /tmp/

  # install apr
  local PRCE=pcre.tar.gz

  echo "Installing PRCE package..."
  wget $PRCEURL -O $PRCE && \
  tar -xzf $PRCE && cd pcre-*

  ./configure --disable-shared --prefix=$PCREPATH && make && $SUDO make install || (echo "failed to compile PRCE " && popd && return 1)
  echo "Installed PRCE package at " $PCREPATH
  rm -rf $APR apr-* $NOSTOUT

  popd $NOSTOUT
}

function install_openssl {
  local SSLPATH=openssl
  local SSLTAR=openssl.tar.gz
  pushd . $NOSTOUT
  cd /tmp/

  echo "Installing OpenSSL..."
  wget $OPENSSLURL -O $SSLTAR && \
  tar -xzf $SSLTAR && cd open*
  ./config --prefix=$OPENSSLPATH shared && \
  make && make install  \
  || (echo "failed to compile OpenSSL " && return 1)
  echo "Installed OpenSSL at " $OPENSSLPATH
  rm -rf $SSLTAR open* $NOSTOUT

  popd $NOSTOUT
}

function install_apache {
  local APPATH=httpd

  pushd . $NOSTOUT

  echo "Installing Apache HTTPD..."
  wget $APACHEBASEURL$RELVERSION.tar.gz -O $APPATH && \
  tar -xzf $APPATH && cd httpd-*

  [ -f $CORECPATCH ] && patch $(find ./ -name core.c) $CORECPATCH || (echo "failed to patch core.c " && popd && return 1)

  ./configure --prefix=$APACHEPATH && make && $SUDO make install || (echo "failed to compile Apache HTTPD " && popd && return 1)

  ./configure --prefix=$APACHEPATH --enable-mods-shared=all \
              --enable-ssl --with-ssl=$OPENSSLPATH \
              --with-apxs=$APACHEPATH --with-apr=$APRPATH \
              --enable-pcre=static --with-pcre=$PCREPATH \
  && make && $SUDO make install \
  || (echo "failed to compile Apache " && return 1)

  valid_apache_configure

  echo "Installed Apache HTTPD at " $APACHEPATH
  rm -rf $APPATH httpd* $NOSTOUT

  popd $NOSTOUT
}


function valid_apache_configure {
  local CONFFILE=$APACHEPATH/conf/httpd.conf
  [ -f $CONFFILE ] || (echo "failed to find $CONFFILE " && return 1)

  grep -q "LoadModule deflate_module modules/mod_deflate.so" $CONFFILE && \
  grep -q "LoadModule proxy_module modules/mod_proxy.so" $CONFFILE && \
  grep -q "LoadModule proxy_connect_module modules/mod_proxy_connect.so" $CONFFILE && \
  grep -q "LoadModule proxy_ftp_module modules/mod_proxy_ftp.so" $CONFFILE && \
  grep -q "LoadModule proxy_http_module modules/mod_proxy_http.so" $CONFFILE && \
  grep -q "LoadModule proxy_scgi_module modules/mod_proxy_scgi.so" $CONFFILE && \
  grep -q "LoadModule proxy_ajp_module modules/mod_proxy_ajp.so" $CONFFILE && \
  grep -q "LoadModule proxy_balancer_module modules/mod_proxy_balancer.so" $CONFFILE

  [ $? == 0 ] && (echo "Valided Apache configuration " && return 0) || \
                 (echo "failed to valid Apache configuration " && return 1)
}

# Assume the function is called within apache source code root path
function build_mod_jk {
  pushd . $NOSTOUT
  local JKPATH=modjk.tar.gz
  echo "Installing mod_jk..."
  wget $MODJKURL -O $JKPATH && \
  tar -xzf $JKPATH

  cd tomcat-connectors-*/native
  ./configure --with-apxs=$APACHEPATH/bin/apxs && make && make install

  [ $? == 0 ] && [ -f $APACHEPATH/bin/apxs ] && \
          echo "Installed Amod_jk at " $APACHEPATH || \
          (echo "failed to installed Amod_jk " && popd && return 1)
  rm -rf $JKPATH tomcat-connectors-* $NOSTOUT

  popd $NOSTOUT
}

function deploy_openssl_to_apach {

  find $OPENSSLPATH/lib -name *ssl* -exec install -p {} $SSLLIBPATH \; && \
  find $OPENSSLPATH/lib -name *crypt* -exec install -p {} $SSLLIBPATH \;

  [ $? == 0 ] && [ -n "$(ls $SSLLIBPATH)" ] \
  && (echo "Deployed Openssl to Appach" && return 0) \
  || (echo "Failed to Deploy Openssl to Appach" && return 1)
}