+++
title = 'Minimal CA With Nitrokey'
date = 2025-06-13T07:04:21+01:00
draft = false
+++

# Minimal CA with Nitrokey

I've been using nitrokey's for personal key management for several years. They can be a little big hard
to use since there isn't much in the way of documentation other than "go and use xca". Which while is 
good advice, doesn't address more advanced setups where the signing operation itself is the bit that
matters.

I wanted to use purely command line tools with as minimal configuration as possible and does not use the hard disk so that signing operations may realistically happen from an ephemeral live booted device with no persistant storage.

Essentially, using openssl there are two ways to achieve this. The "legacy" way using engines and the "modern" way that uses providers. OpenSSL providers were introduced a little while ago in version 3 i think. With the intention of deprecating engines. Therefore the method you use will depend on which version of openssl is bundled with your distro. Regardless of which method used the procedure is roughly the same

- install some dependancies
- init the HSM
- use pkcs11 to generate a key on the HSM
- use the key to self sign a new certificate (the 'CA')
- use the key and CA to sign subordinates.

I have created scripts that work with both the engines and providers approach 

https://gitlab.com/jimmypw/nitrokey-ca-scripts
