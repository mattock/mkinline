mkinline
========

A bash script for converting OpenVPN configuration files into the inline 
certificate format.

To use this script you will need an openvpn configuration file (=input file) 
where "ca", "tls-auth", "key" and "cert" options are pointing to valid 
key/certificate files. It is not necessary to have all of these defined; the 
script will just add all of the certs/keys it can find.

All of the files need to be readable by the current user or the output 
configuration file will be partial. The script works in the following fashion:

1. Parse the cert/key file paths from the input config file
2. Dump the input file into output file without the "ca", "tls-auth", "cert" and 
   "key" entries.
3. Adds the certs and key to the output file in the inline format

Warnings will be printed if the certs/keys could not be read.

usage
=====

In most cases you will need to run this script as root.

    $ ./mkinline.sh -h
    mkinline.sh -i <input-file> -o <output-file>

bugs
====

In some cases parsing the certificate/key paths fails for no apparent reason.
