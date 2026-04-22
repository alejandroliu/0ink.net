#!/usr/bin/python3
import argparse
import hashlib
import hmac
import datetime
import requests
from requests.auth import AuthBase
from urllib.parse import urlparse, quote, urlencode, parse_qsl
import os
import sys
import json


try:
    from icecream import ic
except ImportError:  # Graceful fallback if IceCream isn't installed.
    ic = lambda *a: None if not a else (a[0] if len(a) == 1 else a)  # noqa

VERSION = '0.0'
METADATA_URL = 'http://169.254.169.254/openstack/latest/securitykey'


class OTCAkSkAuth(AuthBase):
    """
    OTC/Huawei Cloud SDK-HMAC-SHA256 request signer.
    Works with both permanent and temporary AK/SK credentials.
    Pass security_token when using temporary credentials from the metadata endpoint.
    """

    def __init__(self, ak, sk, security_token=None):
        self.ak = ak
        self.sk = sk
        self.security_token = security_token

    def __call__(self, r):
        # 1. Timestamp
        dt = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
        r.headers['X-Sdk-Date'] = dt
        if self.security_token:
            r.headers['X-Security-Token'] = self.security_token

        # 2. Parse URL
        parsed = urlparse(r.url)
        # URI must end with / per spec, but trailing slash is not sent
        uri = quote(parsed.path or '/', safe='/-_.~')
        if not uri.endswith('/'):
            uri = uri + '/'

        # Canonical query string: sort params alphabetically
        query_params = sorted(parse_qsl(parsed.query, keep_blank_values=True))
        canonical_query = urlencode(query_params)

        # 3. Build headers to sign
        # Must include host and x-sdk-date; include x-security-token if present
        host = parsed.netloc
        headers_to_sign = {
            'host': host,
            'x-sdk-date': dt,
        }
        # Only include content-type if actually set on the request
        ct = r.headers.get('Content-Type', '')
        if ct:
            headers_to_sign['content-type'] = ct
        if self.security_token:
            headers_to_sign['x-security-token'] = self.security_token

        # Sorted alphabetically
        sorted_headers = sorted(headers_to_sign.items())
        canonical_headers = ''.join(f'{k}:{v}\n' for k, v in sorted_headers)
        signed_headers = ';'.join(k for k, _ in sorted_headers)

        # 4. Hash the request body
        body = r.body or b''
        if isinstance(body, str):
            body = body.encode('utf-8')
        payload_hash = hashlib.sha256(body).hexdigest()

        # 5. Canonical request
        canonical_request = '\n'.join([
            r.method.upper(),
            uri,
            canonical_query,
            canonical_headers,
            signed_headers,
            payload_hash,
        ])

        # 6. String to sign — NOTE: no credential scope, just 3 fields
        hashed_cr = hashlib.sha256(canonical_request.encode('utf-8')).hexdigest()
        string_to_sign = f'SDK-HMAC-SHA256\n{dt}\n{hashed_cr}'

        # 7. Signature — SK used DIRECTLY, no key derivation chain
        signature = hmac.new(
            self.sk.encode('utf-8'),
            string_to_sign.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()

        # 8. Authorization header
        r.headers['Authorization'] = (
            f'SDK-HMAC-SHA256 Access={self.ak}, '
            f'SignedHeaders={signed_headers}, Signature={signature}'
        )
        return r



def parser_factory():
  parser = argparse.ArgumentParser(
                      prog = 'aksk_apicall',
                      description = 'Call T Cloud Public API using AK/SK credentials',
                      epilog = 'Should work with Permanet and Temporary AK/SK pairs',
                      fromfile_prefix_chars = '@',
                      allow_abbrev = True,
                    )

  cgrp = parser.add_mutually_exclusive_group()
  cgrp.add_argument('--metadata','-m',
                      help = 'Retrieve credentials from metadata URL',
                      default = None,
                      )

  cgrp.add_argument('--ak','--access-key','-a',
                        default = os.getenv('OS_ACCESS_KEY',None),
                        help = 'Specified Access Key (or environment: OS_ACCESS_KEY)',
                      )
  parser.add_argument('--sk','--secret-key','-s',
                        default = os.getenv('OS_ACCESS_SECRET',None),
                        help = 'Specified Secret Key (or environment: OS_ACCESS_SECRET)',
                      )
  parser.add_argument('--token','--security-token','-t',
                        default = os.getenv('OS_ACCESS_TOKEN',None),
                        help = 'Specified Secret Key (or environment: OS_ACCESS_TOKEN)',
                      )
  parser.add_argument('--version','-V', action='version', version=VERSION)

  parser.add_argument('verb',
                      choices = [ 'GET', 'PUT', 'POST', 'DELETE' ],
                      help = 'REST API verb',
                    )
  parser.add_argument('url',
                        help = 'End-point URL',
                      )
  parser.add_argument('body',
                      nargs = '?',
                      help = 'JSON text body (if needed)'
                      )
  return parser

def metadata_config(url:str = METADATA_URL):
  '''Retrieve credentials from the metadata server

  :param url: URL to metadata server
  '''
  ic(url)
  response = requests.get(url)
  response.raise_for_status()
  data = response.json()

  ak = data['credential']['access']
  sk = data['credential']['secret']
  security_token = data['credential']['securitytoken']

  return ak,sk,security_token


if __name__ == '__main__':
  parser = parser_factory()
  args = parser.parse_args()

  # ~ if args.metadata:
    # ~ ak,sk,security_token = metadata_config()
  if args.ak:
    if not args.sk:
      parser.error('--sk is required when --ak is specified')
    ak = args.ak
    sk = args.sk
    security_token = args.token
  else:
    if isinstance(args.metadata,str):
      ak,sk,security_token = metadata_config(args.metadata)
    else:
      ak,sk,security_token = metadata_config()

  ic(ak,sk,security_token)
  auth = OTCAkSkAuth(
    ak=ak,
    sk=sk,
    security_token=security_token,
  )
  if args.verb in {'GET','DELETE'}:
    if args.body:
      sys.stderr.write(f'Request body specified with ${args.verb} verb is ignored\n')
    if args.verb == 'GET':
      resp = requests.get(args.url,auth=auth)
    elif args.verb == 'DELETE':
      resp = requests.delete(args.url,auth=auth)
  elif args.verb == 'POST':
    if args.body is None:
      parse.error(f'{args.verb}: Missing request body')
    resp = requests.post(
                      args.url,
                      auth=auth,
                      headers = {'Content-Type': 'application/json' },
                      data=args.body)
  else:
    parser.error(f'{args.verb}: Unimplemented verb')
  print(resp.text)

  resp.raise_for_status()





# ~ resp = requests.get('https://dns.eu-de.otc.t-systems.com/v2/zones',
        # ~ auth=auth)
# ~ print(resp)
# ~ print(resp.json())
