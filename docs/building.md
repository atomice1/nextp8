Build Instructions
==================

Build instructions for Ubuntu 24.04:

* Install build dependencies:
```
sudo apt-get install build-essential cmake g++ gdb-multiarch libc6-dev libcmocka-dev libglu1-mesa-dev libsdl1.2-dev libsdl2-dev libsdl2-image-dev libssl-dev python3 python3-venv sed zip
```
* Checkout [nextp8-dev](https://github.com/atomice1/nextp8-dev):
```
git clone https://github.com/atomice1/nextp8-dev
cd nextp8-dev
```
* Checkout the other repositories:
```
git clone https://github.com/atomice1/femto8-nextp8
git clone https://github.com/atomice1/m68k-elf-gcc
git clone https://github.com/atomice1/nextp8
git clone https://github.com/atomice1/nextp8-bsp
git clone https://github.com/atomice1/nextp8-core
git clone https://github.com/atomice1/nextp8-loader
git clone https://github.com/atomice1/sQLux-nextp8
```
* Build the m68k-elf-gcc toolchain.
```
cd m68k-elf-gcc
./build-toolchain.sh --with-newlib
PATH=$PWD/m68k-toolchain/bin:$PATH
cd ..
```
* Copy the extra model files:
```
cp nextp8-core/c_models/* sQLux-nextp8/
cp femto8-nextp8/src/p8_audio.* sQLux-nextp8/
cp femto8-nextp8/src/p8_dsp.* sQLux-nextp8/
cp femto8-nextp8/src/queue.* sQLux-nextp8/
```
* Build the board support package (BSP):
```
cd nextp8-bsp
PATH=/opt/m68k-toolchain/bin:$PATH make
NEXTP8_BSP=$PWD
export NEXTP8_BSP
cd ..
```
* Build the boot loader:
```
cd nextp8-loader
make
cd ..
```
* Build femto8-nextp8:
```
cd femto8-nextp8
make PLATFORM=nextp8
cd ..
```
* Make a release tarball:
```
./scripts/make-release.sh nextp8.zip
```
* Make a Python virtual environment:
```
python3 -m venv venv
. venv/bin/activate
# Note: pyfatfs depends on pkg_resources which is removed in setuptools 82+.
python3 -m pip install --upgrade pip setuptools==81
python3 -m pip install -r scripts/requirements.txt
```
* Make an SD card image with the femto8-nextp8 binary on it:
```
python3 ./scripts/make-sdcard.py --output sQLux-nextp8/sdcard.img --release-zip nextp8.zip
```
* Build sQLux:
```
cd sQLux-nextp8
git submodule update --init --recursive
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=yes -DSUPPORT_SHADERS=yes -DNEXTP8_BSP=$PWD/../nextp8-bsp -B build
cmake --build build -j 8
```
* Create a link to the bootloader in the roms directory:
```
ln -s ${PWD}/../nextp8-loader/build/loader.bin roms/
```
* Start the model:
```
./build/sqlux
```
