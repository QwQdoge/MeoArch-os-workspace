const tokenTable = document.querySelector("#token-table");
const tabs = Array.from(document.querySelectorAll("[data-token-tab]"));
const grid = document.querySelector("#component-grid");
const search = document.querySelector("#component-search");
const categoryFilter = document.querySelector("#category-filter");

function renderTokens(name) {
  const rows = tokenSections[name] || [];
  tokenTable.innerHTML = `
    <table>
      <thead>
        <tr>
          <th>Token</th>
          <th>Value / maps to</th>
          <th>Use</th>
        </tr>
      </thead>
      <tbody>
        ${rows.map(row => `
          <tr>
            <td><code>${row[0]}</code></td>
            <td>${row[1]}</td>
            <td>${row[2]}</td>
          </tr>
        `).join("")}
      </tbody>
    </table>
  `;
}

function imagePath(name) {
  return `assets/components/${name}.png`;
}

function renderCategories() {
  const categories = ["全部", ...new Set(components.map(item => item[0]))];
  categoryFilter.innerHTML = categories
    .map(category => `<option value="${category}">${category}</option>`)
    .join("");
}

function renderComponents() {
  const q = search.value.trim().toLowerCase();
  const category = categoryFilter.value || "全部";

  const filtered = components.filter(([group, name, description]) => {
    const haystack = `${group} ${name} ${description} ${imagePath(name)}`.toLowerCase();
    const categoryMatch = category === "全部" || group === category;
    return categoryMatch && (!q || haystack.includes(q));
  });

  grid.innerHTML = filtered.map(([group, name, description]) => {
    const file = imagePath(name);
    return `
      <article class="component-card">
        <img src="${file}" alt="${name} placeholder">
        <div class="component-body">
          <div class="component-meta">${group}</div>
          <h3>${name}</h3>
          <p>${description}</p>
          <span class="filename">${file}</span>
        </div>
      </article>
    `;
  }).join("");
}

tabs.forEach(tab => {
  tab.addEventListener("click", () => {
    tabs.forEach(item => item.classList.remove("active"));
    tab.classList.add("active");
    renderTokens(tab.dataset.tokenTab);
  });
});

search.addEventListener("input", renderComponents);
categoryFilter.addEventListener("change", renderComponents);

renderTokens("typography");
renderCategories();
renderComponents();
