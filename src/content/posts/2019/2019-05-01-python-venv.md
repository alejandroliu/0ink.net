---
title: Python Virtual Environments
date: 2019-05-01
tags: information, manager, python, scripts
revised: 2021-12-22
---

This is the least you need to know to get to use a Python virtual
environment.

## What is a Virtual Environment

At its core, the main purpose of Python virtual environments is to
create an isolated environment for Python projects. This means that
each project can have its own dependencies, regardless of what
dependencies every other project has.

The great thing about this is that there are no limits to the number
of environments you can have since they're just directories containing
a few scripts.

## Pre-requisites

While `venv` is part of `python3`, for `python2` you need to install
`virtualenv`.

- void-linux: `python-virtualenv`

## Create

To create a new virtual environment:

### Python2

```
mkdir folder
virtualenv folder
```

If you want to inherit system global packages in your virtual
environment use this instead:

```
mkdir folder
virtualenv --system-site-packages folder
```

### Python3

```
mkdir folder
python3 -m venv folder
```

If you want to inherit system global packages in your virtual
environment use this instead:

```
mkdir folder
python3 -m venv --system-site-packages folder
```

I prefer to use the `--system-site-packages` option, that way
I can have `binary` modules using the host's package manager.
This is in order to avoid having a compiler in the host system.


## Activate

To activate a virtual environment:

```
. <folder>/bin/activate
```

Pay attention that we are using `.` to source the script in
the current interpreter.

## De-Activate

To de-activate:

```
deactivate
```

## Run from a script

To use the virtual environment from a script (i.e. running
as a background daemon) you need to add these to the
beginning of your python script:

```
activate_this = '/path/to/virtualenv/bin/activate_this.py'
execfile(activate_this, dict(__file__=activate_this))
```

Or from a shell cript:

```
#!/bin/sh
source name_Env/bin/activate
# virtualenv is now active.
exec python script.py "$@"
```

## References

For more information see:

- [Python3 venv](https://docs.python.org/3/library/venv.html)
- [pipenv & virtual environments](https://docs.python-guide.org/dev/virtualenvs/)
- [virtual env primer](https://realpython.com/python-virtual-environments-a-primer/)
