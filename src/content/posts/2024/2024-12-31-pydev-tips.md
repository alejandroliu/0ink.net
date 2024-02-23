---
title: Python development tips 2024
date: "2024-02-16"
author: alex
---
[toc]
***

# Local install packages

- Install using a venv and pip
  ```bash
  python3 -m venv --system-site-packages tmpenv
  . tmpenv/bin/activate
  pip install icecream
  ```
- Copy the resulting python lib/python3.12 to /usr/local/lib/python3 (omitting pip)

# Better debugging

So instead of using print for outputing debuging code, you can use icecream:

- [icecream](https://github.com/gruns/icecream)

Interestingly, there are versions for other languages:

- [for PHP](https://github.com/ntzm/icecream-php)
- [for BASH](https://github.com/jtplaarj/IceCream-Bash)

It looks very interesting as it is a better way to get debugging output.  I 
am thinking of using it like this:

```python
try:
    from icecream import ic
    ic.configureOutput(includeContext=True) # Optional... shows source and line numbers
except ImportError:  # Graceful fallback if IceCream isn't installed.
    ic = lambda *a: None if not a else (a[0] if len(a) == 1 else a)  # noqa
```

Requires: python3-executing python3-asttokens python3-colorama


# Adding site specific customizations

When python starts, it will load a module called [sitecustomize](https://docs.python.org/3/library/site.html#module-sitecustomize)
where site specific customizations can be done.  My idea is to have a script
create this:

```bash
#!/bin/sh
type python || exit 1
site_dir=$(python -m site | grep site-packages | tr -d "'," | grep -v USER_SITE | xargs)
if [ -z "$site_dir" ] ; then
  echo "Unable to determine site dir" 1>&2
  exit 2
fi
if [ ! -d "$site_dir ] ; then
  echo "$site_dir: not found" 1>&2
  exit 3
fi
if [ ! -w "$site_dir" ] ; then
  echo "$site_dir: no write access" 1>&2
  exit 4
fi

dd of="$site_dir/sitecustomize.py" <<_EOF_
  import site
  site.addsitedir("/usr/local/lib/python3")
_EOF_
```

# Adding SSL and validate certificates

- https://www.electricmonk.nl/log/2018/06/02/ssl-tls-client-certificate-verification-with-python-v3-4-sslcontext/
- Using asyncio with SSL https://rob-blackbourn.medium.com/secure-communication-with-python-ssl-certificate-and-asyncio-939ae53ccd35
- https requests: https://www.techcoil.com/blog/how-to-send-a-http-request-with-client-certificate-private-key-password-secret-in-python-3/


# Things to watch

- [FastAPI](https://fastapi.tiangolo.com/)
  - Interesting way for creating REST APIs.
- [SQLModel](https://sqlmodel.tiangolo.com/)
  - Not mature enough.  Let's wait until migrations are documented and decide them.

# Packaging code

- Put all python code in a directory
- Create `__init__.py`, which is used when importing the directory.
- Create `__main__.py`, which is called when running `python -m module`
- Refs:
  - https://timothybramlett.com/How_to_create_a_Python_Package_with___init__py.html
  - https://www.geeksforgeeks.org/usage-of-__main__-py-in-python/
  - https://stackoverflow.com/questions/4042905/what-is-main-py



# Others

- https://kislyuk.github.io/argcomplete/ Not sure
- https://pypi.org/project/python-dotenv/ Not sure
- https://github.com/Textualize/rich




