/*
 * SPA code
 */

function switchPage(page_id) {
  var pages = document.querySelectorAll('.spa');
  pages.forEach(page => {
    if (page.id == page_id) {
      page.classList.remove("disabled");
    } else {
      page.classList.add("disabled")
    }
  })
}
function getCurrentDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
    const day = String(today.getDate()).padStart(2, '0');

    return `${year}-${month}-${day}`;
}

function generateQR(event) {
  event.preventDefault();
  var title = document.getElementById('title').value;
  var desc = document.getElementById('desc').value;
  var url = document.getElementById('url').value;
  var payload = document.getElementById('payload').value;

  document.getElementById("show-title").textContent = title;
  document.getElementById("show-desc").textContent = desc;
  document.getElementById("show-url").textContent = url;
  document.getElementById("show-date").textContent = "Generated on: " + getCurrentDate();

  myurl = window.location.href;
  if (url != "") { payload += "\n" + url; }
  encoded = base32.encode(payload);
  to_qr = myurl + "#" + encoded;
  try_url = myurl + "?q=" + Math.random() + "#" + encoded;

  //~ console.log("String length: "+to_qr.length);
  // Should check that the length is less than 1,500 characters
  // and show an error.

  document.getElementById("show-payload").textContent = to_qr;
  var qrdiv = document.getElementById("qrcode");
  qrdiv.textContent = "";
  var qrcode = new QRCode(qrdiv, {
     text: to_qr,
     //~ width: 256,
     //~ height: 256
  });
  switchPage("qrdisplay");

  var link = document.getElementById('try-me');
  link.href = try_url;
}

function goMain() {
  switchPage("home");
}

function decodePage(from_qr) {
  switchPage("error");
  var decoded = base32.decode(from_qr).split("\n");
  if (decoded.length == 0) {
    return;
  }
  document.getElementById("dec-payload").value = decoded[0];
  switchPage("decoded");
  if (decoded.length == 1) {
    return;
  }
  var link = document.getElementById("dec-url");
  link.classList.remove("disabled");
  link.href = decoded[1]
  link.textContent = decoded[1];
  var copier = document.getElementById("copy-url");
  copier.classList.remove("disabled");
}

function copyToClipboard(textToCopy) {
  var tempElement = document.createElement("textarea");
  tempElement.value = textToCopy;
  document.body.appendChild(tempElement);
  tempElement.select();
  document.execCommand("copy");
  document.body.removeChild(tempElement);
}


function copyPayload() {
  copyToClipboard(document.getElementById('dec-payload').value);
}

function copyUrl() {
  var link = document.getElementById("dec-url");
  copyToClipboard(link.href);
}

function main() {
  var hashtext = window.location.hash;
  hashtext = hashtext.substring(1);

  if (hashtext == "") {
    switchPage("home");
  } else {
    decodePage(hashtext);
  }
}

window.onload = function() {
  main();
};

