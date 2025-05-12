---
title: Additional OpenSSL tips
date: "2024-02-19"
author: alex
tags: encryption, openssl, python, browser, idea, alpine, linux, tools, windows, library,
  computer, ~remove, directory, database, configuration, address, information, remote,
  authentication, password, security, application, service, domain
---
[toc]
***
![banner]({static}/images/2026/cas/banner.png)

So the last few articles we have been exploring the world of
certificate authorities (CA).  This is an addendum to that
covering simple one off tasks that are useful in the
context certificates.

# Self-signed certificates

Obviously, if you have a CA, you shouldn't need a self-signed
certificate.  However, being able to issue self-signed
certificates can be useful specially in test scenarios.

This is the command I use for this:

```bash
    openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out "$fqdn.crt" \
            -keyout "$fqdn.key" \
            -subj "/CN=$fqdn" \
            -addext "subjectAltName=DNS:*.api.$fqdn,DNS:www.$fqdn,IP:10.0.0.1"

```
Replace `$fqdn` with the full domain name.

This creates a pair of files `$fqdn.crt` and `$fqdn.key` containing the certificate
and key pair to add to your web server configuration.

The `-subj "/CN=$fqdn"` refers to the main name for the server.  For example:
`example.com`.

The `-addext` is if you want alternative names for the certificate.  Usually this
is useful for implementing wildcard certificates.  It is optional.

# Display cert extensions

```bash
$ openssl x509 -purpose -in root_ca.pem

Certificate purposes:
SSL client : Yes
SSL client CA : Yes
SSL server : Yes
SSL server CA : Yes
Netscape SSL server : Yes
Netscape SSL server CA : Yes
S/MIME signing : Yes
S/MIME signing CA : Yes
S/MIME encryption : Yes
S/MIME encryption CA : Yes
CRL signing : Yes
CRL signing CA : Yes
Any Purpose : Yes
Any Purpose CA : Yes
OCSP helper : Yes
OCSP helper CA : Yes
```

# Viewing certificate information

This is done using the x509 command:

```bash
$ openssl x509 -in RapidSSLCA.pem -noout -text

Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 145105 (0x236d1)
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=US, O=GeoTrust Inc., CN=GeoTrust Global CA
        Validity
            Not Before: Feb 19 22:45:05 2010 GMT
            Not After : Feb 18 22:45:05 2020 GMT
        Subject: C=US, O=GeoTrust, Inc., CN=RapidSSL CA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (2048 bit)
                Modulus (2048 bit):
                    00:c7:71:f8:56:c7:1e:d9:cc:b5:ad:f6:b4:97:a3:
                    fb:a1:e6:0b:50:5f:50:aa:3a:da:0f:fc:3d:29:24:
                    43:c6:10:29:c1:fc:55:40:72:ee:bd:ea:df:9f:b6:
                    41:f4:48:4b:c8:6e:fe:4f:57:12:8b:5b:fa:92:dd:
                    5e:e8:ad:f3:f0:1b:b1:7b:4d:fb:cf:fd:d1:e5:f8:
                    e3:dc:e7:f5:73:7f:df:01:49:cf:8c:56:c1:bd:37:
                    e3:5b:be:b5:4f:8b:8b:f0:da:4f:c7:e3:dd:55:47:
                    69:df:f2:5b:7b:07:4f:3d:e5:ac:21:c1:c8:1d:7a:
                    e8:e7:f6:0f:a1:aa:f5:6f:de:a8:65:4f:10:89:9c:
                    03:f3:89:7a:a5:5e:01:72:33:ed:a9:e9:5a:1e:79:
                    f3:87:c8:df:c8:c5:fc:37:c8:9a:9a:d7:b8:76:cc:
                    b0:3e:e7:fd:e6:54:ea:df:5f:52:41:78:59:57:ad:
                    f1:12:d6:7f:bc:d5:9f:70:d3:05:6c:fa:a3:7d:67:
                    58:dd:26:62:1d:31:92:0c:79:79:1c:8e:cf:ca:7b:
                    c1:66:af:a8:74:48:fb:8e:82:c2:9e:2c:99:5c:7b:
                    2d:5d:9b:bc:5b:57:9e:7c:3a:7a:13:ad:f2:a3:18:
                    5b:2b:59:0f:cd:5c:3a:eb:68:33:c6:28:1d:82:d1:
                    50:8b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
            X509v3 Subject Key Identifier: 
                6B:69:3D:6A:18:42:4A:DD:8F:02:65:39:FD:35:24:86:78:91:16:30
            X509v3 Authority Key Identifier: 
                keyid:C0:7A:98:68:8D:89:FB:AB:05:64:0C:11:7D:AA:7D:65:B8:CA:CC:4E

            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 CRL Distribution Points: 
                URI:http://crl.geotrust.com/crls/gtglobal.crl

            Authority Information Access: 
                OCSP - URI:http://ocsp.geotrust.com

    Signature Algorithm: sha1WithRSAEncryption
        ab:bc:bc:0a:5d:18:94:e3:c1:b1:c3:a8:4c:55:d6:be:b4:98:
        f1:ee:3c:1c:cd:cf:f3:24:24:5c:96:03:27:58:fc:36:ae:a2:
        2f:8f:f1:fe:da:2b:02:c3:33:bd:c8:dd:48:22:2b:60:0f:a5:
        03:10:fd:77:f8:d0:ed:96:67:4f:fd:ea:47:20:70:54:dc:a9:
        0c:55:7e:e1:96:25:8a:d9:b5:da:57:4a:be:8d:8e:49:43:63:
        a5:6c:4e:27:87:25:eb:5b:6d:fe:a2:7f:38:28:e0:36:ab:ad:
        39:a5:a5:62:c4:b7:5c:58:2c:aa:5d:01:60:a6:62:67:a3:c0:
        c7:62:23:f4:e7:6c:46:ee:b5:d3:80:6a:22:13:d2:2d:3f:74:
        4f:ea:af:8c:5f:b4:38:9c:db:ae:ce:af:84:1e:a6:f6:34:51:
        59:79:d3:e3:75:dc:bc:d7:f3:73:df:92:ec:d2:20:59:6f:9c:
        fb:95:f8:92:76:18:0a:7c:0f:2c:a6:ca:de:8a:62:7b:d8:f3:
        ce:5f:68:bd:8f:3e:c1:74:bb:15:72:3a:16:83:a9:0b:e6:4d:
        99:9c:d8:57:ec:a8:01:51:c7:6f:57:34:5e:ab:4a:2c:42:f6:
        4f:1c:89:78:de:26:4e:f5:6f:93:4c:15:6b:27:56:4d:00:54:
        6c:7a:b7:b7
```

# Checking server certificate

This is done using the `s_client` command:

```bash
$ openssl s_client -connect www.google.com:443

CONNECTED(00000003)
depth=1 /C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA
verify error:num=20:unable to get local issuer certificate
verify return:0
---
Certificate chain
 0 s:/C=US/ST=California/L=Mountain View/O=Google Inc/CN=www.google.com
   i:/C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA
 1 s:/C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA
   i:/C=US/O=VeriSign, Inc./OU=Class 3 Public Primary Certification Authority
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIDITCCAoqgAwIBAgIQL9+89q6RUm0PmqPfQDQ+mjANBgkqhkiG9w0BAQUFADBM
MQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkg
THRkLjEWMBQGA1UEAxMNVGhhd3RlIFNHQyBDQTAeFw0wOTEyMTgwMDAwMDBaFw0x
MTEyMTgyMzU5NTlaMGgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlh
MRYwFAYDVQQHFA1Nb3VudGFpbiBWaWV3MRMwEQYDVQQKFApHb29nbGUgSW5jMRcw
FQYDVQQDFA53d3cuZ29vZ2xlLmNvbTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkC
gYEA6PmGD5D6htffvXImttdEAoN4c9kCKO+IRTn7EOh8rqk41XXGOOsKFQebg+jN
gtXj9xVoRaELGYW84u+E593y17iYwqG7tcFR39SDAqc9BkJb4SLD3muFXxzW2k6L
05vuuWciKh0R73mkszeK9P4Y/bz5RiNQl/Os/CRGK1w7t0UCAwEAAaOB5zCB5DAM
BgNVHRMBAf8EAjAAMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwudGhhd3Rl
LmNvbS9UaGF3dGVTR0NDQS5jcmwwKAYDVR0lBCEwHwYIKwYBBQUHAwEGCCsGAQUF
BwMCBglghkgBhvhCBAEwcgYIKwYBBQUHAQEEZjBkMCIGCCsGAQUFBzABhhZodHRw
Oi8vb2NzcC50aGF3dGUuY29tMD4GCCsGAQUFBzAChjJodHRwOi8vd3d3LnRoYXd0
ZS5jb20vcmVwb3NpdG9yeS9UaGF3dGVfU0dDX0NBLmNydDANBgkqhkiG9w0BAQUF
AAOBgQCfQ89bxFApsb/isJr/aiEdLRLDLE5a+RLizrmCUi3nHX4adpaQedEkUjh5
u2ONgJd8IyAPkU0Wueru9G2Jysa9zCRo1kNbzipYvzwY4OA8Ys+WAi0oR1A04Se6
z5nRUP8pJcA2NhUzUnC+MY+f6H/nEQyNv4SgQhqAibAxWEEHXw==
-----END CERTIFICATE-----
subject=/C=US/ST=California/L=Mountain View/O=Google Inc/CN=www.google.com
issuer=/C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA
---
No client certificate CA names sent
---
SSL handshake has read 1772 bytes and written 307 bytes
---
New, TLSv1/SSLv3, Cipher is RC4-SHA
Server public key is 1024 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
SSL-Session:
    Protocol  : TLSv1
    Cipher    : RC4-SHA
    Session-ID: BDE08AD29E65CA4007711610FDD69165F9EB47065716D9AB469DAD9882E6E207
    Session-ID-ctx: 
    Master-Key: 6FE2F273ABAAACF8E99180AAB9D540708F6A392DE1285787121B8A438E68FB3D01C127B31CC39146741D3A8396E0FA79
    Key-Arg   : None
    Start Time: 1311928772
    Timeout   : 300 (sec)
    Verify return code: 20 (unable to get local issuer certificate)
---
```

Things to note:

* The server’s certificate is enclosed by `-----BEGIN CERTIFICATE-----` and
  `-----END CERTIFICATE-----`, this can be saved in a separate file for later reuse.
* The Certificate name, the Subject is
  `/C=US/ST=California/L=Mountain View/O=Google Inc/CN=www.google.com`.
- The Issuer of the certificate, ie the one who signed the certificate, is
  `/C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA`.
- We were unable to check the validity of this certificate (unable to get local issuer
  certificate) because we do not have the Issuer certifcate.

By giving the `-CAfile` parameter we can give the CA certificate file of the CA who
issued the server certificate. Here I guessed the CA certificate file from the Issuer
name:

```bash
$ openssl s_client -connect www.google.com:443 -CAfile /etc/ssl/certs/Verisign_Class_3_Public_Primary_Certification_Authority.pem

CONNECTED(00000003)
depth=2 /C=US/O=VeriSign, Inc./OU=Class 3 Public Primary Certification Authority
verify return:1
depth=1 /C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA
verify return:1
depth=0 /C=US/ST=California/L=Mountain View/O=Google Inc/CN=www.google.com
verify return:1

---
Certificate chain
 0 s:/C=US/ST=California/L=Mountain View/O=Google Inc/CN=www.google.com
   i:/C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA
 1 s:/C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA
   i:/C=US/O=VeriSign, Inc./OU=Class 3 Public Primary Certification Authority
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIDITCCAoqgAwIBAgIQL9+89q6RUm0PmqPfQDQ+mjANBgkqhkiG9w0BAQUFADBM
[ ... ]
SSL-Session:
    Protocol  : TLSv1
    Cipher    : RC4-SHA
    Session-ID: 222E7CFF6DE8425B1B3635F706CDD65083F2758C87095D70E448E27C8272E377
    Session-ID-ctx: 
    Master-Key: B04EBA908A928D7EF7B9432771A0C95A78BA060FBB75383AA081DDF8F8AD31A2F95CD0EF63AC09827A3220E7856EFE28
    Key-Arg   : None
    Start Time: 1311929265
    Timeout   : 300 (sec)
    Verify return code: 0 (ok)
---
```
The server certificate is now considered as valid.

It is not always possible to guess the CA certificate filename, instead use the
`-CApath` to give the directory where resides all the known CA certificates of
your system:

```bash
$ openssl s_client -connect www.google.com:443 -CApath /etc/ssl/certs/


[ ... ]
   Verify return code: 0 (ok)
---
```

# How to create a certificate chain ?

A certificate chain is just a file where multiple PEM files are concatened. PEM files
must be ordered from the last certificate (for example server certificate or client
certificate) to the top Root CA..

```bash
$ cat server_crt.pem operational_ca.pem intermetiade_ca.pem root_ca.pem > certificate_chain.pem
```

# Converting a .pem certificate to pkcs12

PKCS12 is a format to store a certficate AND it’s private key. Because it contains
the private key, it needs to by encrypted. Unlike .pem file, the pkcs12 format is
binary. So you cannot include it in text configuration files; it need to be base64
if needed.

```bash
$ openssl pkcs12 -export \
          -in "blog.quicheaters.org.pem"
          -inkey "blog.quicheaters.org.key" \
          -out "blog.quicheaters.org.p12" \
          -password 'pass:XXXxxxXXX' \
          -certfile "CA/root-ca.pem"
```

# New Apple requirements since 2023

For its newer iOS and macOS Operating Systems, Apple is enforcing new requirements
for certificates. See [apple suppor][as].

Here are ways to create Apple compatible certificates.

I’m using this small openssl configuration file:

```bash
$ cat openssl.cnf
[ req ]
distinguished_name = req
```

## Create a self-signed CA

```bash
openssl req -config ./openssl.cnf \
            -new -x509 -days 3650 -newkey rsa:4096 \
            -keyout CA/-ca.key \
            -passout pass:my_secret_pass \
            -out CA/ca.pem \
            -subj "/C=FR/ST=Ile de France/L=Parise/O=SuperCompany/CN=SuperCompany CA" \
            -addext 'basicConstraints=critical,CA:true' \
            -addext 'subjectKeyIdentifier=hash' \
            -addext 'authorityKeyIdentifier=keyid:always,issuer:always' \
            -addext 'keyUsage=critical,cRLSign,digitalSignature,keyCertSign'

```

## Create a Server Certificate Signing Request

```bash
openssl req -config ./openssl.cnf \
            -new -newkey rsa:4096 -nodes \
            -keyout private/vpn.key \
            -out certreqs/vpn.csr \
            -subj "/C=FR/ST=Ile de France/L=Paris/O=SuperCompany/CN=vpn.example.com" \
            -addext 'basicConstraints=critical,CA:FALSE' \
            -addext 'subjectKeyIdentifier=hash' \
            -addext 'keyUsage=critical,nonRepudiation,digitalSignature,keyEncipherment,keyAgreement' \
            -addext 'extendedKeyUsage=critical,serverAuth' \
            -addext 'subjectAltName=DNS:vpn.example.com,IP:1XX.XX.XX.23'
```

## Sign the Certificate Request

```bash
openssl x509 \
        -req -in certreqs/vpn.csr \
        -CA CA/ca.pem -CAkey CA/ca.key -CAcreateserial \
        -passin pass:my_secret_pass \
        -days 825 \
        -out newcerts/vpn.pem \
        -extfile <(echo 'basicConstraints=critical,CA:FALSE';
                   echo 'subjectKeyIdentifier=hash';
                   echo 'authorityKeyIdentifier=keyid:always,issuer:always';
                   echo 'keyUsage=critical,nonRepudiation,digitalSignature,keyEncipherment,keyAgreement';
                   echo 'extendedKeyUsage=critical,serverAuth';
                   echo 'subjectAltName=DNS:vpn.example.com,IP:1XX.XX.XX.23';)
```

# References

- https://klyr.github.io/posts/various_reminders_about_openssl_and_certificates/
- [Apple requirements for trusted certificates][as]

  [as]: https://support.apple.com/en-us/HT210176
