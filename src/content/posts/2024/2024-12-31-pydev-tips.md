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

Normally, copying virtual environments would not work as paths are hard-coded in
many files.  However, here we are only copying the files in `lib/python3.1` to 
`/usr/local/lib/python3`.  Most python distributions would automatically pick up
files from there.  However, you can force it using `PYTHONPATH` environment variable.

# Better debugging

So instead of using print for outputing debuging code, you can use icecream:

- [icecream][ic]

Interestingly, there are versions for other languages:

- [for PHP][ic-php]
- [for BASH][ic-bash]

It looks very interesting as it is a better way to get debugging output.  I 
am thinking of using it like this:

```python
try:
    from icecream import ic
    ic.configureOutput(includeContext=True) # Optional... shows source and line numbers
except ImportError:  # Graceful fallback if IceCream isn't installed.
    ic = lambda *a: None if not a else (a[0] if len(a) == 1 else a)  # noqa
```

Requires: `python3-executing` `python3-asttokens` `python3-colorama`


# Built-in exceptions

Python prefers the use of exceptions instead of return values to indicate errors.
Since you wouldn't want to create a new exception class for every error you may
need to raise, it is good to have a list of Python's built-in exception handy.

[Python Built-in exceptions][builtin-exceptions]

List of exceptions:

- Generic exceptions
  - Exception
  - ArithmeticError
  - BufferError
- Specific exceptions
  - AssertionError - related to `assert` calls
  - AttributeError - related to object attributes
  - EOFError
  - GeneratorError - raised when a `generator` or a `corroutine` closes
  - ImportError
  - ModuleNotFoundError
  - IndexError - for numeric subscripts (i.e. `list` or `tupples`)
  - KeyError - for `dict`
  - KeyboardInterrupt - ==Control+C==
  - NotImplementedError
  - OSError
  - OverflowError
  - RecursionError
  - ReferenceError
  - RuntimeError - this is the "others" exception.
  - StopIteration - raised by `next()`
  - StopAsyncIteration
  - SyntaxError
  - IndentationError
  - TabError
  - SystemError - An Python interpreter internal error.  These should be reported to the
    python maintainers.
  - SystemExit - raised by `sys.exit()`.
  - TypeError
  - UnboundLocalError
  - UnicodeError
  - UnicodeEncodeError
  - UnicodeDecodeError
  - UnicodeTranslateError
  - ValueError
  - ZeroDivisionError
  - EnvironmentError, IOError, WindowsError - Only applicable to Microsoft Windows
- OS exceptions: These are subclasses of `OSError`.
  - BlockingIOError
  - ChildProcessError
  - ConnectionError
  - BrokenPipeError
  - ConnectionAbortedError
  - ConnectionRefusedError
  - ConnectionResetError
  - FileExistsError
  - FileNotFoundError
  - InterruptedError
  - IsADirectoryError
  - NotADirectoryError
  - PermissionError
  - ProcessLookupError
  - TimeoutError

There are more exceptions but these are not commonly used.

For catching exception, it is useful to refer to the [Exception class tree][exception-tree].


# Adding site specific customizations

When python starts, it will load a module called [sitecustomize][customize]
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

# Constants

While Python doesn't have a constant of constants, the convention in Python is
to write the name in capital letters with underscores separating words.

By using capital letters only, you're communicating that the current name is
intended to be treated as a constant—or more precisely, as a variable that never
changes. So, other Python developers will know that and hopefully won't perform
any assignment operation on the variable at hand.

**NOTE**: Python doesn't support constants or non-reassignable names.
Using uppercase letters is just a convention, and it doesn't prevent developers
from assigning new values to your constant. So, any programmer working on your code
needs to be careful and never write code that changes the values of constants.
Remember this rule because you also need to follow it.

While this may seem pointless (or redundant) this has the following benefits:

| Advantage | Description |
|----|----|
|Improved readability | A descriptive name representing a given value throughout a program is always more readable and explicit than the bare-bones value itself. For example, it's easier to read and understand a constant named `MAX_SPEED` than the concrete speed value itself. |
| Clear communication of intent | Most people will assume that `3.14` may refer to the `Pi` constant. However, using the `Pi`, `pi`, or `PI` name will communicate your intent more clearly than using the value directly. This practice will allow other developers to understand your code quickly and accurately. |
| Better maintainability | Constants enable you to use the same name to identify the same value throughout your code. If you need to update the constant's value, then you don't have to change every instance of the value. You just have to change the value in a single place: the constant definition. This improves your code's maintainability. |
| Lower risk of errors | A constant representing a given value throughout a program is less error-prone than several explicit instances of the value. Say that you use different precision levels for `Pi` depending on your target calculations. You've explicitly used the values with the required precision for every calculation. If you need to change the precision in a set of calculations, then replacing the values can be error-prone because you can end up changing the wrong values. It's safer to create different constants for different precision levels and change the code in a single place. |
| Reduced debugging needs | Constants will remain unchanged during the program's lifetime. Because they'll always have the same value, they shouldn't cause errors and bugs. This feature may not be necessary in small projects, but it may be crucial in large projects with multiple developers. Developers won't have to invest time debugging the current value of any constant. |
| Thread-safe data storage | Constants can only be accessed, not written. This feature makes them thread-safe objects, which means that several threads can simultaneously use a constant without the risk of corrupting or losing the underlying data. |
| Detect typos | A very common mistake specially for string constants is to mispell the value itself.  By making the value a constant, if the constant is mispelled, an error will be raised |


From [realpython][pyconst].


# Adding SSL and validate certificates

## Server side

- ssl server
- https server

## Client side

- https://www.electricmonk.nl/log/2018/06/02/ssl-tls-client-certificate-verification-with-python-v3-4-sslcontext/
- Using asyncio with SSL https://rob-blackbourn.medium.com/secure-communication-with-python-ssl-certificate-and-asyncio-939ae53ccd35
- https requests: https://www.techcoil.com/blog/how-to-send-a-http-request-with-client-certificate-private-key-password-secret-in-python-3/

# Packaging code

- Put all python code in a directory
- Create `__init__.py`, which is used when importing the directory.
- Create `__main__.py`, which is called when running `python -m module`
- Refs:
  - https://timothybramlett.com/How_to_create_a_Python_Package_with___init__py.html
  - https://www.geeksforgeeks.org/usage-of-__main__-py-in-python/
  - https://stackoverflow.com/questions/4042905/what-is-main-py

# Things to watch

- [FastAPI](https://fastapi.tiangolo.com/)
  - Interesting way for creating REST APIs.
- [SQLModel](https://sqlmodel.tiangolo.com/)
  - Not mature enough.  Let's wait until migrations are documented and decide them.

# More [sphinx][sphinx]

After using [sphinx][sphinx] for document generation I find it quite _prickly_
with the slightest mistake breaking thins and error messages that are very 
*uninformative*.

Todo:

- Jinja2 templates or other var substs
- conf.py
  - Handle meta variables
  - How source code is found
  - sphinxarg.ext - argparse auto docs
  - myst_parser - markdown
  - autodoc2 - automatic API doc generation
  - html_static_path


# Others

- https://kislyuk.github.io/argcomplete/ Not sure
- https://pypi.org/project/python-dotenv/ Not sure
- https://github.com/Textualize/rich

  [builtin-exceptions]: https://docs.python.org/3/library/exceptions.html
  [customize]: https://docs.python.org/3/library/site.html#module-sitecustomize
  [ic]: https://github.com/gruns/icecream
  [ic-php]: https://github.com/ntzm/icecream-php
  [ic-bash]: https://github.com/jtplaarj/IceCream-Bash
  [exception-tree]: https://docs.python.org/3/library/exceptions.html#exception-hierarchy
  [sphinx]: https://www.sphinx-doc.org/en/master/
  [pyconst]: https://realpython.com/python-constants/#why-use-constants

