---
title: Python Development 2023
tags: android, directory, python, scripts, windows
---
[toc]
***

# Python development on Windows

For windows, you can use [WinPython][winpython].
I prefer to use this instead of the official distribution because:

1. It is a portable distro.
2. You can choose for a batteries included, or just the `dot` release
   which only contains Python and Pip.

This way I can have multiple versions available.  This is particularly
useful for me because of my [OTC][otc] development which uses
[OpenStack SDK][openstacksdk].  In my Windows system, I was only able
to make it work with Python v3.8.10 (due to some ancient dependancies).
Because I usually don't have a compiler, I can only use binary distros
and I am unable to find it for a newer Python version.

# Distributing Python scripts as single EXE or Directory

When distributing I had good results with [pyinstaller][pyinstaller].
You can create a single folder or a single exe distribution.  The
results work suprisingly well (if they work).  Some hints when using
[pyinstaller][pyinstaller]:

- Cross packaging is not possible.  If you need a Windows package
  you need to run it on Windows.
- Dependancies not always work correctly.  You may need to use
  these options:
  - `--hidden-import module`
  - `--collect-data module`
  - `--copy-metadata module`
  - `--collect-all package`
- In some cases, you may need to force the inclusion of non-python
  files.  Use:
  - `set sitedir=%WINPYDIR%\Lib\site-packages`
  - And in the command line:
  - `--add-data %sitedir%\path\to\data\file;path\to\data`
  - I use the `%sitedir%` variable to find things in the Python packages
    directory.
- It is best to create a batch file to issue the `pyinstaller` command.
- Because the command-line could become quite long, you can use the `^`
  escape.  Example:
  ```
  pyinstaller %buildtype% ^
    --hidden-import keystoneauth1 ^
    --collect-data keystoneauth1 ^
    --copy-metadata keystoneauth1 ^
    --hidden-import os_service_types ^
    --collect-data os_service_types ^
    --copy-metadata os_service_types ^
    --collect-all openstacksdk ^
    --copy-metadata openstacksdk ^
    --add-data %sitedir%\openstack\config\defaults.json;openstack\config ^
    --hidden-import keystoneauth1.loading._plugins ^
    --hidden-import keystoneauth1.loading._plugins.identity ^
    --hidden-import keystoneauth1.loading._plugins.identity.generic ^
  urotc.py
  ```

# Installing `netifaces` on Windows

NOTE: I tested this on Feb 2023.  See
[Original article here](https://allones.de/2018/11/05/python-netifaces-installation-microsoft-visual-c-14-0-is-required/)

`netifaces` is a [OpenStack SDK][openstacksdk] dependancy.  Under
version 3.8.10 I am able to install using `--only-binary=netifaces` option.

For newer versions it will fail with `Microsoft Visual C++ 14.0 is required`
error message.

```
C:\RH>pip install netifaces
Collecting netifaces
  Downloading https://files.pythonhosted.org/packages/81/39/4e9a026265ba944ddf1fea176dbb29e0fe50c43717ba4fcf3646d099fe38/netifaces-0.10.7.tar.gz
Installing collected packages: netifaces
  Running setup.py install for netifaces ... error
    Complete output from command c:\users\rh\appdata\local\programs\python\python37\python.exe -u -c "import setuptools, tokenize;__file__='C:\\Users\\RH\\AppData\\Local\\Temp\\pip-install-wbfanly3\\netifaces\\setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record C:\Users\RONALD~1.HEI\AppData\Local\Temp\pip-record-m26yfbyt\install-record.txt --single-version-externally-managed --compile:
    running install
    running build
    running build_ext
    building 'netifaces' extension
        error: Microsoft Visual C++ 14.0 is required. Get it with "Microsoft Visual C++ Build Tools": http://landinghub.visualstudio.com/visual-cpp-build-tools
```

Since the suggested URL doesn't work.  You need to do the following:

1. Go to the Microsoft-Repository
   [Tools for Visual Studio 2017](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017)
   or use the direct link to
   [vs_buildtools.exe](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=15).
   * ... it’s about 1.2MB
2. run „vs_buildtools.exe“
   * it downloads ~ 70 MB
3. Select `Workloads => Windows => [x] Visual C++ Build Tools“ => [Install]`
   * it downloads 1.12 GB
   * and installs
4. Re-boot (I don't know if it is required, but I did it just in case)

Now `netifaces` can get installed:

```
C:\RH>pip install netifaces
Collecting netifaces
  Using cached https://files.pythonhosted.org/packages/81/39/4e9a026265ba944ddf1fea176dbb29e0fe50c43717ba4fcf3646d099fe38/netifaces-0.10.7.tar.gz
Installing collected packages: netifaces
  Running setup.py install for netifaces ... done
Successfully installed netifaces-0.10.7
```

# GUI programming




***

- Web programming using PYthon3
  - https://brython.info/index.html
  - https://www.transcrypt.org/home
  - https://github.com/metapensiero/metapensiero.pj
  - https://github.com/atsepkov/RapydScript
- https://www.geeksforgeeks.org/how-to-run-javascript-from-python/
  - convert js to python
- Sharepoint connection
  - https://qurios-it.de/2020/10/16/connecting-to-sharepoint-using-python/


***

# GUI programming in Python

**The TLDR**: PySimpleGUI because it is _simple_.  Or Kivy because is multi-platform (i.e. Android and IOS and Desktop).

- [Hitchikers guide to Python GUI](https://docs.python-guide.org/scenarios/gui/)
- [Top 10 frameworks](https://towardsdatascience.com/top-10-python-gui-frameworks-for-developers-adca32fbe6fc)
- [PySimpleGUI](https://realpython.com/pysimplegui-python/)
- [Python3 GUI overview](https://www.geeksforgeeks.org/python3-gui-application-overview/)
- [Modern Tkinter](https://medium.com/@fareedkhandev/modern-gui-using-tkinter-12da0b983e22)

[otc]: https://open-telekom-cloud.com "Open Telekom Cloud"
[openstacksdk]: https://wiki.openstack.org/wiki/SDKs
[winpython]: https://winpython.github.io/
[pyinstaller]: https://pyinstaller.org/en/stable/
