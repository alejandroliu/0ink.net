---
title: javascript snippets
---
[TOC]

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



