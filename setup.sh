#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $RALPM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $RALPM_TMP_DIR/cpython-3.9.13.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/cpython-3.9.13.tar.gz

  wget https://github.com/ohjeongwook/dumpflash/archive/fc0c3e13909c9f08e8a4ad90a5a7e0bc02ae1544.tar.gz -O $RALPM_TMP_DIR/dumpflash.tar.gz
  tar xf $RALPM_TMP_DIR/dumpflash.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/dumpflash.tar.gz
  mv $RALPM_PKG_INSTALL_DIR/dumpflash-fc0c3e13909c9f08e8a4ad90a5a7e0bc02ae1544 $RALPM_PKG_INSTALL_DIR/dumpflash
  
  $RALPM_PKG_INSTALL_DIR/python/bin/pip3.9 install pyftdi pyusb libusb1

  for tool in dumpflash dumpjffs2
  do
    echo '#!/usr/bin/env sh' > $RALPM_PKG_BIN_DIR/$tool
    echo "$RALPM_PKG_INSTALL_DIR/python/bin/python3.9 $RALPM_PKG_INSTALL_DIR/dumpflash/dumpflash/$tool.py \"\$@\"" >> $RALPM_PKG_BIN_DIR/$tool
    chmod +x $RALPM_PKG_BIN_DIR/$tool
  done

  echo "This package adds the commands:"
  echo " - dumpflash"
  echo " - dumpjffs2"
}

uninstall() {
  rm -rf $RALPM_PKG_BIN_DIR/python
  rm $RALPM_PKG_BIN_DIR/dumpflash
  rm $RALPM_PKG_BIN_DIR/dumpjffs2  
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1