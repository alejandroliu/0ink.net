---
title: Calculate system availability
---

To calculate the availability of redundant systems you can
use this formula:

```
total_avail = 1-(1 - single_avail) ^ (number_of_nodes)
```

<form action="">
Nodes: <input type="number" id="nodes" name="nodes" min="0" maxlength="4" value="2" onchange="myCalculation();" /><br/>
Single component availability (%): <input type="number" id="savail" name="savail" min="0" maxlength="10"value="99.00" onchange="myCalculation();" /><br/>
Total Availability: <input name="total" id="total" type="number" maxlength="20" min="0" placeholder="00.00" readonly="true" />
</form>

<script>
function myCalculation() {
var nodes = parseInt(document.getElementById('nodes').value,10);
var sava = parseFloat(document.getElementById('savail').value);
var result = (1-(1-sava/100.0)**(nodes))*100
document.getElementById('total').value = result
}
</script>
