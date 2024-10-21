---
title: Python development tips 2024
date: "2024-02-16"
author: alex
---
[toc]
***

![python]({static}/images/2024/python.png)

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

# Using Environment Variables for Configuration

Learn how experienced developers use environment variables in Python, including managing
default values and typecasting.

From [Doppler][doppler] blog.


As a developer, you’ve likely used environment variables in the command line or shell scripts,
but have you used them as a way of configuring your Python applications?

This guide will show you all the code necessary for getting, setting, and loading environment
variables in Python, including how to use them for supplying application config and secrets.

## Why use environment variables for configuring Python applications?

Before digging into how to use environment variables in Python, it's important to
understand why they're arguably the best way to configure applications. The main
benefits are:

- Deploy your application in any environment without code changes
- Ensures secrets such as API keys are not leaked into source code

Environment variables have the additional benefit of abstracting from your application how
config and secrets are supplied.

Finally, environment variables enable your application to run anywhere, whether it's for local
development on macOS, a container in a Kubernetes Pod, or platforms such as Heroku or Vercel.

Here are some examples of using environment variables to configure a Python script or application:

- Set `FLASK_ENV` environment variable to `"development"` to enable debug mode for a
  Flask application
- Provide the `STRIPE_API_KEY` environment variable for an Ecommerce site
- Supply the `DISCORD_TOKEN` environment variable to a Discord bot app so it can join a server
- Set environment specific database variables such as `DB_USER` and `DB_PASSWORD` so database
  credentials are not hard-coded
  
## How are environment variables in Python populated?

When a Python process is created, the available environment variables populate the `os.environ`
object which acts like a Python dictionary. This means that:

- Any environment variable modifications made after the Python process was created will not
  be reflected in the Python process.
- Any environment variable changes made in Python do not affect environment variables in the
  parent process.

Now that you know how environment variables in Python are populated, let's look at how to access them.

## How to get a Python environment variable

Environment variables in Python are accessed using the `os.environ` object.

The `os.environ` object seems like a dictionary but is different as values may only be
strings, plus it's not serializable to JSON.

You've got a few options when it comes to referencing the `os.environ` object:


```python
# 1. Standard way

import os

# os.environ['VAR_NAME']


# 2. Import just the environ object

from os import environ

# environ['VAR_NAME']


# 3. Rename the `environ` to env object for more concise code

from os import environ as env

# env['VAR_NAME']
```

Accessing a specific environment variable in Python can be done in one of three ways, depending
upon what should happen if an environment variable does not exist.

Let's explore with some examples.

### Option 1: Required with no default value

If your app should crash when an environment variable is not set, then access it directly:

```python
print(os.environ['HOME']

# >> '/home/dev'


print(os.environ['DOES_NOT_EXIST']

# >> Will raise a KeyError exception
```

For example, an application should fail to start if a required environment variable is not set,
and a default value can't be provided, e.g. a database password.

If instead of the default `KeyError` exception being raised (which doesn't communicate why
your app failed to start), you could capture the exception and print out a helpful message:

```python
import os
import sys

# Ensure all required environment variables are set
try:  
  os.environ['API_KEY']
except KeyError: 
  print('[error]: `API_KEY` environment variable required')
  sys.exit(1)
```

### Option 2: Required with default value

You can have a default value returned if an environment variable doesn't exist by using the
`os.environ.get` method and supplying the default value as the second parameter:

```python

# If HOSTNAME doesn't exist, presume local development and return localhost

print(os.environ.get('HOSTNAME', 'localhost')
```


If the variable doesn't exist and you use `os.environ.get` without a default value, `None`
is returned

```python
assert os.environ.get('NO_VAR_EXISTS') == None
```

### Option 3: Conditional logic if value exists

You may need to check if an environment variable exists, but don't necessarily care about its
value. For example, your application can be put in a _"Debug mode"_ if the `DEBUG` environment
variable is set.

You can check for just the existence of an environment variable:

```python
if 'DEBUG' in os.environ:
  print('[info]: app is running in debug mode')
```

Or check to see it matches a specific value:

```python
if os.environ.get('DEBUG') == 'True':
  print('[info]: app is running in debug mode')
```

## How to set a Python environment variable

Setting an environment variable in Python is the same as setting a key on a dictionary:

```python
os.environ['TESTING'] = 'true'
```

What makes `os.environ` different to a standard dictionary, is that only string values are allowed:

```python
os.environ['TESTING'] = True
# >> TypeError: str expected, not bool
```

In most cases, your application will only need to get environment variables, but there are use
cases for setting them as well.

For example, constructing a `DB_URL` environment variable on application start-up using
`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` environment variables:

```python
os.environ['DB_URL'] = 'psql://{user}:{password}@{host}:{port}/{name}'.format(
  user=os.environ['DB_USER'],
  password=os.environ['DB_PASSWORD'],
  host=os.environ['DB_HOST'],
  port=os.environ['DB_PORT'],
  name=os.environ['DB_NAME']
)
```

Another example is setting a variable to a default value based on the value of another variable:

```python
# Set DEBUG and TESTING to 'True' if ENV is 'development'
if os.environ.get('ENV') == 'development':
  os.environ.setdefault('DEBUG', 'True') # Only set to True if DEBUG not set
  os.environ.setdefault('TESTING', 'True') # Only set to True if TESTING not set
```

## How to delete a Python environment variable

If you need to delete a Python environment variable, use the `os.environ.pop` function:

To extend our `DB_URL` example above, you may want to delete the other `DB_` prefixed
fields to ensure the only way the app can connect to the database is via `DB_URL`:

Another example is deleting an environment variable once it is no longer needed:

```python
auth_api(os.environ['API_KEY']) # Use API_KEY
os.environ.pop('API_KEY') # Delete API_KEY as it's no longer needed
```

## Why default values for environment variables should be avoided

You might be surprised to learn it's best to **avoid providing default values**
as much as possible. Why?

Default values can make debugging a misconfigured application more difficult, as the
final config values will likely be a combination of hard-coded default values and
environment variables.

Relying purely on environment variables (or as much as possible) means you have a single
source of truth for how your application was configured, making troubleshooting easier.

## Using a .env file for Python environment variables

As an application grows in size and complexity, so does the number of environment variables.

Many projects experience growing pains when using environment variables for app config
and secrets because there is no clear and consistent strategy for how to manage them,
particularly when deploying to multiple environments.

A simple (but not easily scalable) solution is to use a `.env` file to contain all of the
variables for a specific environment.

Then you would use a Python library such as [python-dotenv][dotenv] to parse the `.env` file
and populate the `os.environ` object.

Using [python-dotenv][dotenv], you can save the below to a file named `.env` (note how it's the
same syntax for setting a variable in the shell):

```python
API_KEY="357A70FF-BFAA-4C6A-8289-9831DDFB2D3D"
HOSTNAME="0.0.0.0"
PORT="8080"
```

Then save the following to `dotenv-test.py`:

```python
# Rename `os.environ` to `env` for nicer code
from os import environ as env

from dotenv import load_dotenv
load_dotenv()


print('API_KEY:  {}'.format(env['API_KEY']))
print('HOSTNAME: {}'.format(env['HOSTNAME']))
print('PORT:     {}'.format(env['PORT']))
```

Then run `dotenv-test.py` to test the environment variables are being populated:

```bash
python3 dotenv-test.py
# >> API_KEY:  357A70FF-BFAA-4C6A-8289-9831DDFB2D3D
# >> HOSTNAME: 0.0.0.0
# >> PORT:     8080
```

While `.env` files are simple and easy to work with at the beginning, they also cause a new
set of problems such as:

- How to keep `.env` files in-sync for every developer in their local environment?
- If there is an outage due to misconfiguration, accessing the container or VM directly in
  order to view the contents of the .env may be required for troubleshooting.
- How do you generate a `.env` file for a CI/CD job such as GitHub Actions without
  committing the `.env` file to the repository?
- If a mix of environment variables and a `.env` file is used, the only way to determine
  the final configuration values could be by introspecting the application.
- Onboarding a developer by sharing an unencrypted `.env` file with potentially sensitive
  data in a chat application such as Slack could pose security issues.


  [builtin-exceptions]: https://docs.python.org/3/library/exceptions.html
  [customize]: https://docs.python.org/3/library/site.html#module-sitecustomize
  [ic]: https://github.com/gruns/icecream
  [ic-php]: https://github.com/ntzm/icecream-php
  [ic-bash]: https://github.com/jtplaarj/IceCream-Bash
  [exception-tree]: https://docs.python.org/3/library/exceptions.html#exception-hierarchy
  [pyconst]: https://realpython.com/python-constants/#why-use-constants
  [doppler]: https://www.doppler.com/blog/environment-variables-in-python
  [dotenv]: https://github.com/theskumar/python-dotenv

