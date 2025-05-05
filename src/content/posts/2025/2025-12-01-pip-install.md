---
title: Installing source using PIP
date: "2025-05-05"
author: alex
tags: python, github, git, tools, installation, manager, setup, directory, configuration
---
[toc]
***
![banner]({static}/images/2025/pipinst/banner.png)


# Installing from github


You can install a Python module directly from a GitHub repository using `pip` by specifying
the repository's URL. Here’s how you do it:

```sh
pip install git+https://github.com/username/repository.git
```

![github logo]({static}/images/2025/pipinst/github_logo.png)


Replace `username` with the owner of the repository and `repository` with the name of the
repository. If the module is inside a subdirectory, or if the repository has different
branches, you might need to specify the path like this:

```sh
pip install git+https://github.com/username/repository.git@branch_name
```

You can install a specific tag from a GitHub repository using pip by appending the tag name
to the repository URL with an `@` symbol. Here's how:

```sh
pip install git+https://github.com/username/repository.git@tag_name
```
![pip logo]({static}/images/2025/pipinst/pip_logo.png)


When using `pip` to install a package directly from a GitHub repository, `pip` interacts with
GitHub as follows:

1. **Fetching the Repository** – `pip` uses Git to clone the specified repository to your local
   machine. This is done using the `git+https://github.com/...` URL format.   
2. **Checking Out the Code** – If you specify a branch, tag, or commit hash, `pip` checks out
   that specific version of the repository.
3. **Looking for `setup.py` or `pyproject.toml`** – Once cloned, `pip` searches for a `setup.py`
   file (for traditional Python packages) or `pyproject.toml` (for modern builds using tools like
   Poetry). It uses this file to determine dependencies and installation steps.
4. **Installing Dependencies** – If the package has dependencies listed, `pip` installs them
   before installing the main package itself.
5. **Building & Installing** – If the package needs compiling or building wheels, `pip` handles
   that and then installs the package into your environment.

Essentially, `pip` acts as both a package manager and a tool for fetching repositories from GitHub
dynamically. It's a convenient way to install Python packages that aren't published on PyPI yet.

# Installing from ZIP file

If you want to install a Python package from a `.zip` file hosted on a web server
using `pip`, you can do it like this:

```sh
pip install https://example.com/path/to/package.zip
```

![ziplogo]({static}/images/2025/pipinst/winzip_logo.png)


## How It Works:

- `pip` downloads the ZIP file from the specified URL.
- It extracts the contents and looks for a `setup.py` or `pyproject.toml` file to determine
  how to install the package.
- If dependencies are listed, `pip` installs them before installing the package itself.

## Alternative: Local ZIP File Installation

If you’ve already downloaded the ZIP file, you can install it locally using:

```sh
pip install /path/to/package.zip
```

If the package is structured correctly, this method works seamlessly.


# Creating a Python package

![python logo]({static}/images/2025/pipinst/python_logo.png)


If you're creating a Python package, the minimal `setup.py` file should include:

```python
from setuptools import setup

setup(
    name="your_package_name",
    version="0.1",
    packages=["your_package"],
)
```
Alternatively you could:
```python
from setuptools import setup
from source import VERSION

setup(
    name="your_package_name",
    version=VERSION,
    packages=["your_package"],
)
```

## Explanation:

- `name`: Defines the package name.
- `version`: Sets the version number.  In the alternatively option, the version
  comes from the source package itself.
- `packages`: Specifies the directory containing your Python modules.

For a more complete `setup.py`, you'd usually include:

- `author`, `description`, `long_description`
- `install_requires` for dependencies
- `entry_points` if your package includes a command-line tool

The ZIP file should be structured like a typical Python package to ensure `pip` can
install it properly. Here's an example of how the contents should be organized:

```
package.zip
│── your_package/                # Main package directory
│   ├── __init__.py              # Makes it a Python package
│   ├── module.py                # Your actual Python code
│── setup.py                      # Installation configuration
│── requirements.txt              # Optional: Dependencies list
│── README.md                     # Optional: Project info
```

I saw examples, where the actual python code is named `core.py` and in `__init__.py` they
would have:

```python
from .core import *
```
You may also want to import or define a `VERSION` id.


### Key Components:

- **`your_package/`** – The actual package directory with your Python modules.
- **`__init__.py`** – An empty file (or containing initialization code) that marks the directory
  as a package.
- **`setup.py`** – Defines metadata, dependencies, and installation instructions for the package.
- **`requirements.txt`** – If the package has dependencies, list them here.
- **`README.md`** – Optional, but useful for explaining your package.

To create this ZIP file, navigate to the package directory and run:
```sh
zip -r package.zip your_package setup.py requirements.txt README.md
```

Once zipped, `pip` can install it like:
```sh
pip install https://example.com/package.zip
```

You can use the same structure for a Git repository.


## Single file python modules

If your module is just a single Python file rather than a full package, you can still create a
ZIP file for installation with `pip`. Here’s how your ZIP structure should look:

```
module.zip
│── module.py              # Your entire Python module
│── setup.py               # Installation configuration
│── requirements.txt       # Optional: Dependencies list
│── README.md              # Optional: Project info
```

### `setup.py` Example for a Single File:
```python
from setuptools import setup

setup(
    name="module_name",
    version="0.1",
    py_modules=["module"],  # Instead of 'packages', use 'py_modules'
)
```

### Creating the ZIP File:
```sh
zip -r module.zip module.py setup.py requirements.txt README.md
```

### Installing with `pip`:
```sh
pip install https://example.com/module.zip
```

This works similarly to installing a full package, but since there’s only one file, you
use `py_modules` instead of `packages` in `setup.py`.


