---
title: Manual Verification of a X.509 Certificate in PHP
tags:
    - php
    - security
    - webdev
categories:
    - development
draft: yes
---

From known CAs

Is meant for PHP 7.2
using the openssl

arbitrary ASN.1 structures


I'm certain that this whole post could be accomplished in an `openssl cli` one-liner.

Still, for reasons, I have to do this validation on PHP 


The challenge is as follow

Only using public information



I'm verifing SAT X.509 issued by SAT México (the Mexican Tax Authority), I know they use __ standard certificates
but I'm not 100% certain that they are _not_ using any special .. 


Their root certificates are self-signed

and are published on their official website





openSSL implementation on PHP
openSSL only uses PEM formatted certificates.

PEM files are a _text representation_ of DER encoding, which is actually a binary ASN.1 askldjflaksdjf

To build, or _coerce_, a DER file to a PEM file::

the following snippet:



What we are doing is taking the binary contents and encoding them in base64, then we _chunk_ them into 64 characters per line, inserting a newline `\n` character when necessary. Finally, we add both a prefix and suffix string that indicates the type of PEM file we have, such as a X.509 Certificate, a Public Key, a Private Key, among many others.




## Wrapping up


The final script is published under my sat-cfdi library, as a Utility class 





Certificate Chains




"name": "Friedrich Große",
            "email": "friedrich.grosse@gmail.com",
            "homepage": "https://github.com/FGrosse",
            "role": "Author"


References
https://linuxctl.com/2017/02/x509-certificate-manual-signature-verification/
https://github.com/FGrosse/PHPASN1