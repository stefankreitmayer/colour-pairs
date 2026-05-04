const ROUND_PAUSE_MS = 1400;
const app = document.querySelector("#app");

let state = {
  screen: "welcome",
  round: 0,
  cards: [],
  locked: false,
};

function step(seed) {
  return (seed * 7621 + 1) % 32768;
}

function nextInt(maxExclusive, seed) {
  return step(seed) % maxExclusive;
}

function randomColor(seed) {
  let current = seed;

  for (let attempt = 0; attempt < 80; attempt += 1) {
    const red = nextInt(256, current);
    const green = nextInt(256, red);
    const blue = nextInt(256, green);

    if (red + green + blue < 720) {
      return { red, green, blue };
    }

    current = step(current);
  }

  return { red: 80, green: 120, blue: 180 };
}

function colorDistance(a, b) {
  return (
    Math.abs(a.red - b.red) +
    Math.abs(a.green - b.green) +
    Math.abs(a.blue - b.blue)
  ) / (3 * 255);
}

function paletteQuality(colors) {
  if (colors.length < 2) return 1;

  let minimum = 1;
  for (let i = 0; i < colors.length; i += 1) {
    for (let j = i + 1; j < colors.length; j += 1) {
      minimum = Math.min(minimum, colorDistance(colors[i], colors[j]));
    }
  }

  return minimum;
}

function randomPalette(count, seed, targetQuality) {
  const colors = [];
  let currentSeed = seed;
  let quality = targetQuality;

  while (colors.length < count) {
    const candidate = randomColor(currentSeed);
    currentSeed = step(currentSeed);

    if (paletteQuality([candidate, ...colors]) >= quality) {
      colors.unshift(candidate);
    } else {
      quality *= 0.99;
    }
  }

  return colors.map(({ red, green, blue }) => `rgb(${red}, ${green}, ${blue})`);
}

function rotate(items, amount) {
  if (items.length === 0) return items;
  const offset = amount % items.length;
  return [...items.slice(offset), ...items.slice(0, offset)];
}

function createCards(round, seed = Math.floor(performance.now() / 100)) {
  const count = Math.floor(round / 2) * 2 + 4;
  const rows = count / 2;
  const unique = randomPalette(count - 1, seed, 1 / count);
  const contents = rotate([unique[0], ...rotate(unique, nextInt(count - 1, seed))], nextInt(count, step(seed)));

  return contents.map((color, index) => ({
    id: `${round}-${index}-${color}`,
    color,
    selected: false,
    matched: false,
    fading: false,
    x: index < rows ? 0.18 : 0.82,
    y: rows === 1 ? 0.5 : 0.1 + 0.8 * (index % rows) / (rows - 1),
  }));
}

function startGame() {
  state = {
    screen: "play",
    round: 0,
    cards: createCards(0, 0),
    locked: false,
  };
  render();
}

function toggleCard(cardId) {
  if (state.locked) return;

  state.cards = state.cards.map((card) => (
    card.id === cardId ? { ...card, selected: !card.selected } : card
  ));

  const selected = state.cards.filter((card) => card.selected);
  if (selected.length === 2 && selected[0].color === selected[1].color) {
    state.locked = true;
    state.cards = state.cards.map((card) => (
      card.selected
        ? { ...card, matched: true, x: 0.5, y: 0.5 }
        : { ...card, fading: true }
    ));
    window.setTimeout(nextRound, ROUND_PAUSE_MS);
  }

  render();
}

function nextRound() {
  if (!state.locked) return;

  const next = state.round + 1;
  state = {
    screen: "play",
    round: next,
    cards: createCards(next),
    locked: false,
  };
  render();
}

function renderWelcome() {
  app.innerHTML = `
    <section class="welcome" aria-labelledby="game-title">
      <div>
        <p class="eyebrow">Two-player tablet game</p>
        <h1 id="game-title">Colour Pairs</h1>
        <p class="goal">Select the two matching colours. Each round adds more choices.</p>
      </div>
      <button class="play-button" type="button">Play</button>
    </section>
  `;

  app.querySelector(".play-button").addEventListener("click", startGame, { passive: true });
}

function renderPlay() {
  const board = document.createElement("section");
  board.className = "board";
  board.setAttribute("aria-label", `Round ${state.round + 1}`);
  board.style.setProperty("--rows", String(state.cards.length / 2));

  const status = document.createElement("div");
  status.className = "round-counter";
  status.textContent = `Round ${state.round + 1}`;
  board.append(status);

  for (const card of state.cards) {
    const button = document.createElement("button");
    button.className = "card";
    button.type = "button";
    button.style.setProperty("--x", card.x);
    button.style.setProperty("--y", card.y);
    button.style.background = card.color;
    button.setAttribute("aria-label", card.selected ? "Selected colour" : "Colour");
    button.setAttribute("aria-pressed", String(card.selected));

    if (card.selected) button.classList.add("is-selected");
    if (card.matched) button.classList.add("is-matched");
    if (card.fading) button.classList.add("is-fading");

    button.addEventListener("pointerdown", (event) => {
      event.preventDefault();
      button.setPointerCapture(event.pointerId);
      toggleCard(card.id);
    });

    board.append(button);
  }

  app.replaceChildren(board);
}

function render() {
  if (state.screen === "welcome") {
    renderWelcome();
  } else {
    renderPlay();
  }
}

window.addEventListener("contextmenu", (event) => event.preventDefault());
window.addEventListener("touchmove", (event) => event.preventDefault(), { passive: false });

render();
