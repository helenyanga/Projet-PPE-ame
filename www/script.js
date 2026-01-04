const selector = document.getElementById("csv-selector");
const table = document.getElementById("metadata-table");
const thead = table.querySelector("thead");
const tbody = table.querySelector("tbody");
const corpusTitle = document.getElementById("corpus-title");
const csvTitles = {
    "tableaux/tableau-ru1.csv": "Corpus RU1 – душа",
    "tableaux/tableau-ru2.csv": "Corpus RU2 – дух"
};
function loadCSV(file) {
    // Clear the table
    thead.innerHTML = "";
    tbody.innerHTML = "";
    clearTable(table);

    fetch(`tableaux/${file}`)
        .then(res => res.text())
        .then(text => {
            const rows = parseCSV(text);
            const header = rows[0];
            const data = rows.slice(1);

            // Render using passed elements
            renderHeaders(header, thead);
            renderBody(header, data, tbody);

            // Update the corpus title
            corpusTitle.innerHTML = csvTitles[file] || "Corpus";
            document.title = corpusTitle.innerHTML;
        })
        .catch(err => console.error("Error loading CSV:", err));
}


// Event listener for dropdown
selector.addEventListener("change", () => {
    const selectedFile = selector.value;
    if (!selectedFile) return; // nothing selected
    loadCSV(selectedFile);
});

// === Load first CSV by default ===
window.addEventListener("DOMContentLoaded", () => {
    // Pick the first value that has a filename
    const firstOption = Array.from(selector.options).find(opt => opt.value);
    if (firstOption) {
        selector.value = firstOption.value;
        loadCSV(firstOption.value);
    }
});

function parseCSV(text){
    // split file into lines
    const lines = text.trim().split("\n");
    // split lines into rows
    return lines.map(line => line.split(";"));
}

function renderHeaders(header, thead) {
    thead.innerHTML = "";
    const tr = document.createElement("tr");
    header.forEach(col => {
        const th = document.createElement("th");
        th.textContent = col;
        tr.appendChild(th);
    });
    thead.appendChild(tr);
}

function renderBody(header, data, tbody) {
    tbody.innerHTML = "";
    data.forEach(row => {
        const tr = document.createElement("tr");
        row.forEach((cell, i) => {
            const td = document.createElement("td");
            if (header[i] === "KWIC") {
                const a = document.createElement("a");
                a.href = `kwic.html?file=${cell}`;
                a.textContent = "Voir KWIC";
                td.appendChild(a);
            } else if (header[i] === "URL") {
                const a = document.createElement("a");
                a.href = cell;
                a.textContent = "Source";
                a.target = "_blank";
                td.appendChild(a);
            } else if (header[i] === "TXT_DUMP") {
                const a = document.createElement("a");
                a.href = cell;
                a.textContent = "Voir dump";
                td.appendChild(a);
            } else if (header[i] === "HTML_DUMP") {
                const a = document.createElement("a");
                a.href = cell;
                a.textContent = "Voir dump HTML";
                td.appendChild(a);
            } else if (header[i] === "HTTP_CODE"){
                const code = Number(cell);
                if (code >= 200 && code < 300){
                    td.classList.add('success');
                } else if (code >= 300 && code < 400){
                    td.classList.add('redirection');
                } else if(code >= 400 && code < 500){
                    td.classList.add('client-error');
                } else if(code >= 500 && code < 600){
                    td.classList.add('server-error');
                } else{
                    td.classList.add('other-code');
                }
                td.textContent = cell;
            }
            else {
                td.textContent = cell;
            }
            tr.appendChild(td);
        });
        tbody.appendChild(tr);
    });
}

function clearTable(table) {
    table.querySelector("thead").innerHTML = "";
    table.querySelector("tbody").innerHTML = "";
}