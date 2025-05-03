---
title: Using Excel files from Python
date: "2025-05-03"
author: alex
tags: python, windows, linux, integration, library, markdown, installation
---
[TOC]

***

![py x excel]({static}/images/2025/py-excel/pyxl.png)

# Intro


The other day I had to create a report in Excel using Python for work.

Python has no shortage of libraries to create Excel files.  There are
portable solutions that would work on Windows and Linux, as well
as solutions that only run on Windows and depend on Excel being
available.

They have their pros and ther cons.  This is a run down of
the possible options.

# XlsxWriter

![xlsxwriter demo]({static}/images/2025/py-excel/xlsxwriter-demo.png)

The first option I tried was [XlsxWriter][xw].  This solution is cross-platform,
being compatible with Linux and Windows.  It does not have many dependancies.
It however is limited to writing only and does not support creating VBA macros
in the created Excel files.


[XlsxWriter][xw] is a Python module for writing files in the Excel 2007+ XLSX file format.

[XlsxWriter][xw] can be used to write text, numbers, formulas and hyperlinks to multiple
worksheets and it supports features such as formatting and many more, including:

- 100% compatible Excel XLSX files.
- Full formatting.
- Merged cells.
- Defined names.
- Charts.
- Autofilters.
- Data validation and drop down lists.
- Conditional formatting.
- Worksheet PNG/JPEG/GIF/BMP/WMF/EMF images.
- Rich multi-format strings.
- Cell comments.
- Integration with Pandas and Polars.
- Textboxes.
- Support for adding Macros.
- Memory optimization mode for writing large files.

It supports Python 3.4+ and PyPy3 and uses standard libraries only.

It is ideal for generating reports and has a very pythonic API.

# openpyxl

![openpyxl logo]({static}/images/2025/py-excel/openpyxl-logo.png)

This is the second option.  The main advantage over [XlsxWriter][xw] is that allows
reading existing xlsx files as well as writing.  Like [XlsxWriter][xw] it is a
portable library, able to run on Windows and Linux.  It does not have any 
strange dependancies.  The main disadvantage I found is that it is a bit
temperamental, and the order of how you do things can impact the output
of the generated file.  The API specifically is a bit wonky with
things being non-intuitive.  Also, like [XlsxWriter][xw], [openpyxl][op]
does not support reading or writing VBA macros.

[openpyxl][op] is a Python library to read/write Excel 2010 xlsx/xlsm/xltx/xltm files.

It was born from lack of existing library to read/write natively from Python
the Office Open XML format.

It was initially based on the [PHPExcel][pe] library.

If you have to read and write Excel files on Linux as well as Windows, this
seems to be the way to go.  However, be prepared for a steep learning curve
and do a lot of trial and error to get things working right.

# xlwings

![xlwings banner]({static}/images/2025/py-excel/xlwings.png)

The third option is [xlwings][xl].  This is a _freemium_ library that has multiple
versions with different capabilities.  These are:

- [xlwings open source](https://docs.xlwings.org/en/latest/) \
  xlwings (Open Source) is a BSD-licensed Python library that makes it easy to call Python
  from Excel and vice versa:
  - Scripting: Automate/interact with Excel from Python using a syntax close to VBA.
  - Macros: Replace VBA macros with clean and powerful Python code.
  - UDFs: Write User Defined Functions (UDFs) in Python (Windows only)
- [xlwings pro](https://docs.xlwings.org/en/0.24.2/pro.html) \
  xlwings pro adds these features:
  - One-click Installer: Easily build your own Python installer including all dependencies—your
    end users don’t need to know anything about Python.
  - Embedded code: Store your Python source code directly in Excel for easy deployment.
  - xlwings Reports: A template-based reporting mechanism, allowing business users to change
    the layout of the report without having to touch the Python code.
  - Markdown Formatting: Support for Markdown formatting of text in cells and shapes like e.g.,
  	text boxes.
  - Permissioning of Code Execution: Control which users can run which Python modules via xlwings.
  - Table.update(): An easy way to keep an Excel table in sync with a pandas DataFrame
- [xlwings lite](https://lite.xlwings.org/) \
  xlwings Lite brings the VBA experience into the modern age by offering a privacy-first,
  secure, and developer-friendly way to automate Excel and write custom functions with Python.
- [xlwings server](https://server.xlwings.org/en/latest/) \
  xlwings Server adds Python support to Microsoft Excel and Google Sheets without the need of
  a local Python installation. xlwings Server is self-hosted and runs on any platform that
  supports Python or Docker, including bare-metal servers, Linux-based VMs, Docker Compose,
  Kubernetes and serverless products like Azure functions or AWS Lambda.

For the simple use case of reading and writing Excel file data it is a bit of an overkill.
It does support adding VBA code to Excel files, however there are limitations associated
with the VBA object model.  So while code can be added, classes and expred modules
can not.

# Conclusions

For strictly writing Excel files, [XlsxWriter][xw] is more than enough.  It is easier
to use and have a nice Pythonic API.

For reading and writing Excel files, [openpyxl][op] is enough, despite its flaws.

If you need limited support for VBA code, [xlwings][xl] is the best option.

# Hints and Tips

![hings and tips]({static}/images/2025/py-excel/hints-tips.png)

## OpenPyxl

[openpyxl][op] has a lot of quirks.  Here is a number of things I discovered:

### Data Validation

![openpyxl data validation]({static}/images/2025/py-excel/openpyxl-datavalidation.png)

This is documented in
[openpyxl Data Validation](https://openpyxl.readthedocs.io/en/latest/validation.html) and
[data validation module](https://openpyxl.readthedocs.io/en/stable/api/openpyxl.worksheet.datavalidation.html).

Data validators can be applied to ranges of cells but are not enforced or evaluated. Ranges
do not have to be contiguous: eg. “A1 B2:B5” is contains A1 and the cells B2 to B5 but not A2
or B2.

Example:

```python

# Create a data-validation object with list validation
dv = DataValidation(type="list", formula1='"Dog","Cat","Bat"', allow_blank=True)

```

The `formula1` is a formula that can contain a list.  The list is comma separated.
You can use double quotes if you need to escape values with commas.  Double quotes can
be escaped by entering two double quotes.   (i.e. in general, it folows Excel formula
syntax).

The other strange thing is that if you want to show a drop down box with the list options
you can add the keyword argument `showDropDown`.  If you want to *see* the dropdown, set
this to **False**.  If you want to hide it, set it to **True**.

### Creating groups

![openpyxl groups]({static}/images/2025/py-excel/openpyxl-groups.png)

For creating grouips you can use

```
  worksheet.column_dimensions.group(start, end, **kwargs)
  worksheet.row_dimensions.group(start, end, **kwargs)

```

Keyword args:

- hidden : hide group
- outline_level : for multilevel groupings

There a further restrictions with creating groups, in that:

1. you must create the cells in the groups before grouping
2. if you are using multi-level groups, you must create the outer-group first
   before creating the inter groups.


## xlwings

Some tips when using [xlwings][xl]:




***

- TODO: COM automation
- xlwings hings and tips


   [xw]: https://github.com/jmcnamara/XlsxWriter
   [op]: https://foss.heptapod.net/openpyxl/openpyxl
   [pe]: https://github.com/phpexcel/PHPExcel
   [xl]: https://www.xlwings.org/
