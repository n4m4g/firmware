#!/usr/bin/env bash

set -e

FIRMWARE=$1
EXT=${1##*.}
FIRMWARE_STRIPPED="${FIRMWARE: 0:-4}-stripped.${EXT}"
FIRMWARE_STRIPPED_DYCRYPTED="${FIRMWARE: 0:-4}-stripped-decrypted.${EXT}"

FIRWARE_MOD_KIT="firmware-mod-kit"
ENCRYPTOR="buffalo-enc"
BUFFALO_ENC_C="buffalo-enc.c"
BUFFALO_LIB_C="buffalo-lib.c"
BIN_DIR="bin"

LEGACY_FILES=($FIRMWARE_STRIPPED $FIRMWARE_STRIPPED_DYCRYPTED $ENCRYPTOR)


# Check input file exist

if [[ ! -f $FIRMWARE ]]; then
    echo ">>> $FIRMWARE not FOUND!!"
    echo ">>> Exit the program..."
    exit 1
else
    echo ">>> Found firmware: $FIRMWARE"
fi
echo ""


# Check whether the firmware need to decrypt
FIRST_4_BYTES=`xxd $FIRMWARE | head -n1 | cut -c 11-19`
if [[ $FIRST_4_BYTES == "2705 1956" ]]; then
    echo ">>> Firmware: $FIRMWARE is READY to flash..."
    echo ">>> Exit the program..."
    exit 1
fi


# Clean legacy files

echo ">>> Clean legacy files..."
for f in ${LEGACY_FILES[@]}; do
    [[ -f $f ]] && echo "rm $f" && rm $f
done
echo ""


# Strip the firmware up to second start section

if [[ -f "$FIRMWARE" ]]; then
    echo ">>> Start stripping $FIRMWARE up to second start section..."
    dd if=$FIRMWARE of=$FIRMWARE_STRIPPED bs=208 skip=1
else
    echo ">>> $FIRMWARE not FOUND!!"
    echo ">>> Exit the program..."
    exit 1
fi
echo ""


# Prepare encryptor

if [[ ! -f "$ENCRYPTOR" ]]; then
    echo ">>> Start building the encryptor: $BIN_DIR/$ENCRYPTOR"
    mkdir -p $BIN_DIR
    gcc -o $BIN_DIR/$ENCRYPTOR $FIRWARE_MOD_KIT/$BUFFALO_ENC_C $FIRWARE_MOD_KIT/$BUFFALO_LIB_C
fi
echo ""


# Decrypt the stripped firmware

if [[ -f "$FIRMWARE_STRIPPED" ]]; then
    echo ">>> Start decrypting $FIRMWARE_STRIPPED..."

    if [[ -f "$BIN_DIR/$ENCRYPTOR" ]]; then
        ./$BIN_DIR/$ENCRYPTOR -d -i $FIRMWARE_STRIPPED -o $FIRMWARE_STRIPPED_DYCRYPTED
    else
        echo ">>> $BIN_DIR/$ENCRYPTOR not FOUND!!!"
        exit
    fi
fi
echo ""

# Check whether build image successfully

FIRST_4_BYTES=`xxd $FIRMWARE_STRIPPED_DYCRYPTED | head -n1 | cut -c 11-19`

if [[ -f "$FIRMWARE_STRIPPED_DYCRYPTED" ]]; then
    if [[ $FIRST_4_BYTES == "2705 1956" ]]; then
        echo ">>> Build image: $FIRMWARE_STRIPPED_DYCRYPTED SUCCESSFULLY!!!"
    else
        echo "Image: $FIRMWARE_STRIPPED_DYCRYPTED has WRONG dycryption: $FIRST_4_BYTES"
        echo "Expect '2705 1956' but got \'$FIRST_4_BYTES\'"
    fi
else
    echo ">>> Build image: $FIRMWARE_STRIPPED_DYCRYPTED FAILED!!!"
fi

# dd if=wzrhpg450h-pro-r30360.enc of=wzrhpg450h-pro-r30360-stripped.enc bs=208 skip=1
# ./buffalo-enc -d -i wzrhpg450h-pro-r30360-stripped.enc -o wzrhpg450h-pro-r30360-stripped-decrypted.enc
