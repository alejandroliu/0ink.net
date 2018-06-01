---
ID: "369"
post_author: "2"
post_date: "2013-05-27 11:55:36"
post_date_gmt: "2013-05-27 11:55:36"
post_title: Network wiring notes - 8P8C / RJ45
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: network-wiring-notes-8p8c-rj45
to_ping: ""
pinged: ""
post_modified: "2016-11-02 12:57:57"
post_modified_gmt: "2016-11-02 12:57:57"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=369
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Network wiring notes - 8P8C / RJ45
...
---

<h3>What you were probably looking forT568A/B (10-BASE-T and 100-BASE-TX):</h3>

<p>With pin positions are counted from <em>left to right</em> with the <em>contacts facing</em> you (clip on the back) and pointing up <em>(cable coming out the bottom):</em></p>

<table>
<thead>
<tr>
  <th>Color (568B)</th>
  <th>Pin</th>
  <th>Color(568A)</th>
</tr>
</thead>
<tbody>
<tr>
  <td>Orange-white</td>
  <td>1</td>
  <td>Green-white</td>
</tr>
<tr>
  <td>Orange</td>
  <td>2</td>
  <td>Green</td>
</tr>
<tr>
  <td>Green-white</td>
  <td>3</td>
  <td>Orange-white</td>
</tr>
<tr>
  <td>Blue</td>
  <td>4</td>
  <td>Blue</td>
</tr>
<tr>
  <td>Blue-white</td>
  <td>5</td>
  <td>Blue-white</td>
</tr>
<tr>
  <td>Green</td>
  <td>6</td>
  <td>Orange</td>
</tr>
<tr>
  <td>Brown-white</td>
  <td>7</td>
  <td>Brown-white</td>
</tr>
<tr>
  <td>Brown</td>
  <td>8</td>
  <td>Brown</td>
</tr>
</tbody>
</table>

<img src="https://noicknis.sirv.com/1/files/2013/05/wiring1.jpg?scale.width=250&scale.height=206" width="250" height=206" alt="wiring1" class="alignnone size-full s3_image-975" />

<p>Cut the outer insulation and order the wires (right), cut for equal length (not shown), and insert into plug (left)</p>

<img src="https://noicknis.sirv.com/1/files/2013/05/wiring2.jpg?scale.width=280&scale.height=110" width="280" height=110" alt="wiring2" class="alignnone size-full s3_image-976" />

<p>Check that the wires go to the end of the plug by seeing if you can see each wire at the end, preferably see its copper reflecting (left).</p>

<p>Then use the crimping tool (shoves the pins into the wires, and fixes the wire in the plug.</p>

<p><em>100Mbit ethernet</em> (Fast Ethernet, FE) uses only two pairs - pins 1, 2, 3, and 6, which in the standard wiring are the orange and green wire pairs.</p>

<p>This means you could use the other wires for different things - e.g. one link and a phone (non-conflicting if you use the stand pins for each), or some more custom combination such as two links though one wire.</p>

<p><em>Gigabit ethernet</em> uses all four pairs, so has no creative options.</p>

<h1>On crossover cables</h1>

<p>Given the two plug colorings in 568-type wiring, cables wired with these can be:</p>

<ul>
<li>A <em>straight cable</em>, 568B-568B (or the functionally equivalent 568A-568A, but in terms of colors the B-B variant seems to be used everywhere, probably to avoid confusion)</li>
<li>A <em>crossover cable</em> (also <em>patch cable</em>) has 568A on one end and 568B on the other. (crossing is also effectively done by a switch or hub, so you can use straight cables except in cases where you don't use switches. Crossovers can be useful for direct computer-computer connections).</li>
</ul>

<p>Gigabit ethernet doesn't need crossovers -- it decided to handle that case inside the NIC and switches rather than have you do it the cable. You use straight cables everywhere (NIC-switch-NIC and NIC-NIC).</p>

<p>Gigabit crossovers are rumored to exist (crossing blue and brown in addition to orange and green), but they are unnecessary.</p>

<h1>On Loopbacks</h1>

<p>Loopbacks connect a port to itself. This can be used to test whether a long cable and/or its wallplug is broken, and whether a switch/router port is broken (or perhaps dirty or corroded), both just by seeing whether the link light comes on.</p>

<p>Connect:</p>

<ul>
<li>Pin 1 to 3</li>
<li>Pin 2 to 6</li>
<li>Pin 4 to 7   (for a gBit loopback)</li>
<li>Pin 5 to 8   (for a gBit loopback)</li>
</ul>

<p>(If you're wiring a plug as a loopback, make sure you're not confused about which end is pin is pin 1).
To create a loopback from a plug-with-cable you cut (that was wired according to 568A or 568B), this means:</p>

<pre><code>Orange-white  to  Green-white 
Orange        to  Green
Blue          to  Brown-white  (for a gBit loopback)
Brown         to  Blue-white   (for a gBit loopback)
</code></pre>

<h1>gBit loopback is a limited concept:</h1>

<p>Gigabit NICs have crosstalk detection (detects how much signal interferes onto other wires), and will likely decide that the loopback is an extreme amount of crosstalk - any may not show link. Meaning it's often only useful on NICs which let you disable crosstalk detection.
Gigabit switches may behave differently (but I'm not sure what the spec says or the real-world variation is)</p>

<p>More notes on ethernet wiring</p>

<p>The wiring used on 10Mbit, 100Mbit (specifically 10-BASE-T and 100-BASE-TX) ethernet over 8P8C (informally RJ45) plugs is defined by <em>TIA/EIA-568-B</em>, which define two plug wiring alternatives, 568A and 568B. Notice the lack of dashes; 568-B is the standard they are part of, 568-A a completely different standard (yes, that naming is stupidly confusing).</p>

<p>Note that both 10Mbit and 100Mbit networking use only pair 2 and 3 (orange and green) in the standard (The blue pair is pair 1, orange is pair 2, green is pair 3, and brown is pair 4.)</p>

<p>This means that Americans or anyone else using 4P/6P-style phone connectors can use fully wired cables (most are fully wired - relatively few (cheaper) cables are only two-pair for only Ethernet) to wire their house/company and have the same sockets be usable to plug in phones, a computer (or both with a trivial splitter). Various companies can use use this to make their wiring simpler.</p>

<h1>Gigabit ethernet</h1>

<p>GBit ethernet can use cables wired 568-style, preferably rated Cat5e, or better.</p>

<p>Specifically, you want straight wiring and four-pair cable. Most older cables are, so can be used at gBit speeds, as 1000-BASE-T uses all four pairs instead of just two.</p>

<p>(If you press your own plugs, it is suggested that you keep the untwisted length as small as possible, to minimize near-end crosstalk)</p>

<p>Some implications:</p>

<ul>
<li>you can't do the phone/networking split mentioned above</li>
<li>on-the-cheap two-pair cables will work, but only because the NICs fall back to 100mbit</li>
<li>you can mix 10/100/1000 in your network, by replacing switches (handy for partial/gradual upgrades), without having to wire about the cabling.</li>
</ul>

<p>...as long as the cable is rated Cat5e (or better)</p>

<h1>On cable standards (Cat5, etc.)</h1>

<ul>
<li>Cat5

<ul>
<li>rarely seen - it has fallen out of favour and is barely sold</li>
<li>(...but your company may still be wired with it)</li>
<li>regularly and informally refers to Cat5a</li>
</ul></li>
<li>Cat5a

<ul>
<li>Currently still quite common</li>
<li>100mBit, 1gBit at &lt;100m</li>
</ul></li>
<li>Cat6

<ul>
<li>100mBit, 1gBit at &lt;100m</li>
<li>&lt;55m for 10gBit (less if many are bundled)</li>
</ul></li>
<li>Cat6a

<ul>
<li>10GBit at &lt;100m</li>
</ul></li>
<li>Cat7 - stricter about crosstalk (pairs individually insulated)</li>
</ul>

<p>Any cabling that is not shielded will crosstalk, meaning permissible distances are lower when many are bundled (relevant to company wiring), or be likely to get a lot of outside interference.</p>

<p>The Shiny Special Expensive cables sold in the sort of computer shops that only sell things that come in plastic boxes are generally not necessary, particularly not on the few-meter cables for your home LAN.</p>

<p>For example, Cat6 was made for 10gBit, most single computers don't have a source of data to actually use that speed, and even if they had, it's hard to get a 10gBit switch.</p>

<p>Companies may want Cat6 (or perhaps Cat6a) for future compatibility, to be able to use gBit now and assuming that nothing replaces copper before the next update.</p>

<p>Cat7 can go beyond 10gBit at short-ish distances, but chances are you won't be needing that any time soon. Only data centers might care.</p>

<h1>Naming pendantics and telephony</h1>

<p>When we say RJ45, we often mean something like "Ethernet wiring on an 8P8C plug."</p>

<p>RJ is the group of plugs that can be described by their positions and connectors, such as 8P8C in Ethernet, while RJ45 actually refers to a specific telephone wiring on the 8P-style plug (probably the most common one among several), while 8P8C refers to that plug itself and no specific wiring. Regardless, most people call the plug RJ45, regardless of wiring.</p>

<p>Plugs may have fewer actually present conductors than they have positions, so 8P2C, 8P4C, 8P6C, 8P8C, 6P2C, 6P4C, 6P6C, 4P2C, 4P4C all exist.</p>

<p>When there are less connectors than positions, they are in the middle positions; RJ-style wiring is from the middle out.</p>

<p>For most of us, the is interesting only in that you can plug a phone with 6P plugs into a 8P (ethernet-plus-phone) socket and have the phone work - the clip aligns the plug in the middle.</p>

<p>If more more than the middle two wires are used in telephone wiring, they carry either power, or a second (RJ14) or even third (RJ25) telephone line on the same wire, but consumers rarely see this type of phone wiring)}}</p>

<p>There are exceptions to the 'always start in the middle', but they tend to be intentionally working around RJ-style wiring.</p>

<p>The most common use of 6P outside of the US is probably phone wiring according to RJ11, which often use just a single pair in the middle. In the US, 8P connectors with the RJ45 phone wiring is common.</p>

