#!/bin/sh

# # remove everything but the static library and this script
ls | grep -v build.sh | xargs rm -rf

export OLD_CONFIGURE=../js/src/old-configure

# configure
python ../configure.py \
            --enable-project=js \
            --enable-release \
            --enable-strip \
            --enable-shared-js \
            --enable-export-js \
            --disable-jemalloc \
            --disable-tests \
            --disable-debug \
            --with-intl-api
            

#             # 
# # make
mozmake -j8