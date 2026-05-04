import { readFile } from "node:fs/promises";

const requiredFiles = ["index.html", "src/app.js", "src/styles.css"];
const requiredHtml = [
  '<meta name="viewport"',
  'viewport-fit=cover',
  '<script type="module" src="./src/app.js"',
  '<link rel="stylesheet" href="./src/styles.css"',
];
const requiredCss = [
  "touch-action: none",
  "100svh",
  "env(safe-area-inset-top)",
  "--card-size",
  "76svh",
  "top 2000ms",
  "left 2000ms",
  "box-shadow 2000ms",
  "will-change",
];
const requiredJs = [
  "addEventListener(\"pointerdown\"",
  "setPointerCapture",
  "createCards",
  "randomPalette",
  "leftDuplicateRow",
  "rightDuplicateRow",
  "MATCH_ANIMATION_MS = 2000",
  "MATCH_HOLD_MS = 500",
];

async function read(path) {
  try {
    return await readFile(path, "utf8");
  } catch {
    throw new Error(`Missing ${path}`);
  }
}

function assertIncludes(content, needles, path) {
  for (const needle of needles) {
    if (!content.includes(needle)) {
      throw new Error(`${path} is missing expected content: ${needle}`);
    }
  }
}

const [html, js, css] = await Promise.all(requiredFiles.map(read));

assertIncludes(html, requiredHtml, "index.html");
assertIncludes(js, requiredJs, "src/app.js");
assertIncludes(css, requiredCss, "src/styles.css");

if (css.includes("0 0 0 0.35rem #191713")) {
  throw new Error("Selected cards should not use the old black outline");
}

const tabletViewports = [
  { name: "iPad portrait", width: 820, height: 1180 },
  { name: "iPad landscape", width: 1180, height: 820 },
  { name: "Android portrait", width: 800, height: 1280 },
  { name: "Android landscape", width: 1280, height: 800 },
];

for (const viewport of tabletViewports) {
  const viewportMin = Math.min(viewport.width, viewport.height);

  for (let rows = 2; rows <= 18; rows += 1) {
    const cardSize = Math.min(8.5 * 16, Math.max(2.25 * 16, Math.min(0.13 * viewportMin, 0.76 * viewport.height / rows)));
    const rowGap = rows === 1 ? viewport.height : 0.8 * viewport.height / (rows - 1);
    const columnGap = 0.64 * viewport.width;

    if (cardSize > rowGap) {
      throw new Error(`${viewport.name}: cards overlap vertically at ${rows} rows`);
    }

    if (cardSize * 1.28 > columnGap) {
      throw new Error(`${viewport.name}: selected cards overlap horizontally at ${rows} rows`);
    }
  }
}

console.log("Static app checks passed.");
