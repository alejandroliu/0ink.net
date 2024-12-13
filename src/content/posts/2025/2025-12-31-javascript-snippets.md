---
title: javascript snippets
date: "2023-08-27"
author: alex
tags: javascript, ~remove
---
[TOC]

![icon]({static}/images/2024/js-icon.png)

# Compute how an element is hidden


Check if element is hidden

```javascript
function isHidden(el) {
    var style = window.getComputedStyle(el);
    return (style.display === 'none')
}
```

# Iterate over LI elements

```html
<ul id="foo">
  <li>First</li>
  <li>Second</li>
  <li>Third</li>
</ul>
```

you can access the list items this way,

```javascript
var ul = document.getElementById("foo");
var items = ul.getElementsByTagName("li");
for (var i = 0; i < items.length; ++i) {
  // do something with items[i], which is a <li> element
}
```

# Adding/removing classes to/from elements

This snippet will add class `foo` to all the elements with `spa` class:

```javascript
var items = document.querySelectorAll(".spa");
items.forEach(item => {
  item.classList.add("foo");
});
```

This snippet will remove class `foo` from all the elements with `spa` class:

```javascript
var items = document.querySelectorAll(".spa");
items.forEach(item => {
  item.classList.remove("foo");
});
```

# Get current date as YYYY-MM-DD

```javascript
function getCurrentDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
    const day = String(today.getDate()).padStart(2, '0');

    return `${year}-${month}-${day}`;
}
```

# escape HTML characters

```javascript
function escapeHTML(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
}
```

Of course, if you want to add strings to HTML you can just:

```javascript
document.getElementById('element-id').textContent = str;
```

Which will automatically escape HTML.

# Copy to Clipboard

```javascript
function copyToClipboard(textToCopy) {
  var tempElement = document.createElement("textarea");
  tempElement.value = textToCopy;
  document.body.appendChild(tempElement);
  tempElement.select();
  document.execCommand("copy");
  document.body.removeChild(tempElement);
}
```

* Creates a temporary `textarea` element, sets its value to the string you want to copy,
  and appends it to the document body.
* The function then selects the text inside the temporary `textarea`, executes the copy
  command, and removes the textarea from the document body.

The reason we temporarily add a `textarea` element to the document is to leverage the
browser’s built-in copy functionality, which typically works only on user-selected text
or content within a focusable element like an input or textarea. 

This workaround is necessary because `document.execCommand('copy')` relies on the text
being selected within an editable field, and a hidden `textarea` is a simple way to
fulfill that requirement. Without adding it to the document, the text wouldn't be
part of the DOM, and the copy command wouldn’t work.

