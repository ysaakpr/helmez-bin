#!/bin/sh

rm -rf temp
mkdir temp
cp plugin/* temp/
cd temp

cp ../bin/helmez-bin.linux.amd64  ./helmez.bin && tar -czvf ../bin/helmez.linux.amd64.tgz  plugin.yaml run.sh helmez.bin
cp ../bin/helmez-bin.linux.386    ./helmez.bin && tar -czvf ../bin/helmez.linux.386.tgz    plugin.yaml run.sh helmez.bin
cp ../bin/helmez-bin.darwin.amd64 ./helmez.bin && tar -czvf ../bin/helmez.darwin.amd64.tgz plugin.yaml run.sh helmez.bin
cp ../bin/helmez-bin.darwin.386   ./helmez.bin && tar -czvf ../bin/helmez.darwin.386.tgz   plugin.yaml run.sh helmez.bin

cd ../
rm -rf temp