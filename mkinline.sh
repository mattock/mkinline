#!/bin/bash
#
# mkinline.sh
#
# A bash script for converting OpenVPN configuration files into the inline
# certificate format.

usage() {
    echo "mkinline.sh -i <input-file> -o <output-file>"

    if [ "$1" == "ERROR" ]; then
        exit 1
    else
        exit 0
    fi
}

param_missing() {
    echo "ERROR: parameter $1 missing"
    echo
    usage "ERROR"
}

file_not_writable() {
    echo "ERROR: file $1 is not writable!"
    exit 1
}

cert_not_added() {
    echo "NOTICE: $1 not found."
}

get_filename_from_config() {
    grep -E "^$1 " $2|awk ' { print $NF } '
}

get_tls_auth_filename_from_config() {
    grep -E "^$1 " $2|awk ' { print $NF - 1 } '

}

append_cert() {
    # $1 = tag, $2 = cert/key, $3 = output, $4 = key-direction
    if ! [ -z "$4" ]; then
        echo "key-direction $4" >> "$3"
    fi

    echo "<$1>" >> "$3"
    cat "$2" >> "$3"
    echo "</$1>" >> "$3"
}

while getopts "i:o:h" options; do
  case $options in
        i ) INPUT=$OPTARG;;
        o ) OUTPUT=$OPTARG;;
        h ) usage;;
       \? ) usage;;
        * ) usage;;
  esac
done

# Verify the options
if [ -z "$INPUT" ]; then param_missing "-i"; fi
if [ -z "$OUTPUT" ]; then param_missing "-o"; fi
if ! `touch "$OUTPUT"`; then file_not_writable "$OUTPUT"; fi

# Dump the input file without the "tls-auth", "ca", "cert" and "key" entries
# into the output file.
grep -v -E "(^ca|^cert|^key|^tls-auth) " "$INPUT" > "$OUTPUT"

# Get filenames from the input configuration file
CA=$(get_filename_from_config "ca" "$INPUT")
TLS_AUTH=`grep -E "^tls-auth " "$INPUT"|awk ' { print $(NF-1) } '`
CERT=$(get_filename_from_config "cert" "$INPUT")
KEY=$(get_filename_from_config "key" "$INPUT")
KEY_DIRECTION=`grep -E "^tls-auth " "$INPUT"|awk ' { print $NF } '`

if ! [ -z "TLS_AUTH" ] && [ -r "$TLS_AUTH" ]; then append_cert "tls-auth" "$TLS_AUTH" "$OUTPUT" "$KEY_DIRECTION"; else cert_not_added "tls-auth key"; fi
if ! [ -z "$CA" ] && [ -r "$CA" ]; then append_cert "ca" "$CA" "$OUTPUT"; else cert_not_added "ca certificate"; fi
if ! [ -z "$CERT" ] && [ -r "$CERT" ]; then append_cert "cert" "$CERT" "$OUTPUT"; else cert_not_added "client certificate"; fi
if ! [ -z "KEY" ] && [ -r "$KEY" ]; then append_cert "key" "$KEY" "$OUTPUT"; else cert_not_added "client key"; fi
