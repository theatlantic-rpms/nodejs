#!/bin/sh
SCRIPTROOT=$(pwd)
version=$(rpm -q --specfile --qf='%{version}\n' nodejs.spec | head -n1)

if [ ! -e node-v${version}.tar.gz ]; then
    wget http://nodejs.org/dist/v${version}/node-v${version}.tar.gz
fi

tar -zxf node-v${version}.tar.gz
rm -rf node-v${version}/deps/openssl/openssl

rm -rf openssl
fedpkg clone -a openssl
pushd openssl
fedpkg prep
openssl_version=$(rpm -q --specfile --qf='%{version}\n' openssl.spec | head -n1)

pushd openssl-${openssl_version}
git init
git add .
git commit -m "Initial commit" --no-gpg-sign
./config
pushd include/openssl
#../../../../copy_symlink.sh *.h
popd # include/openssl

git add include/ crypto/opensslconf.h
git commit -m "Include headers" --no-gpg-sign
git clean -f
popd # openssl-${openssl_version}

popd # openssl
mv openssl/openssl-${openssl_version} node-v${version}/deps/openssl/openssl

tar -zcf node-v${version}-hobbled.tar.gz node-v${version}
