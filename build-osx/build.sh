#!/bin/sh

cpus=$(sysctl hw.ncpu | awk '{print $2}')

export OLD_CONFIGURE=../js/src/old-configure

# configure
python ../configure.py \
            --enable-project=js \
            --enable-optimize=-O3 \
            --disable-shared-js \
            --disable-tests \
            --disable-debug \
            --without-intl-api \
            --enable-jemalloc
            

#             # 
# # make
xcrun make -j$cpus

rm -f ./dist/sdk/lib/libmozglue.a
cp ./mozglue/build/libmozglue.a ./dist/sdk/lib/
cp ./js/src/libjs_static.a ./dist/sdk/lib/
cp -pr dist/include ./dist/sdk/lib/include

# strip
# xcrun strip -S ./dist/sdk/lib/libjs_static.a
# xcrun strip -S ./dist/sdk/lib/libmozglue.a

rm -rf ./release-dist
cp -pr ./dist ./release-dist
