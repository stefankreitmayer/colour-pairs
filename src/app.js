const MATCH_ANIMATION_MS = 2000;
const MATCH_HOLD_MS = 500;
const ROUND_PAUSE_MS = MATCH_ANIMATION_MS + MATCH_HOLD_MS;
const RESTART_CONFIRM_MS = 3000;
const app = document.querySelector("#app");
let restartConfirmTimer = null;
let nextRoundTimer = null;

let state = {
  screen: "welcome",
  round: 0,
  cards: [],
  locked: false,
  restartConfirm: false,
};

function clearRestartConfirm() {
  if (restartConfirmTimer) {
    window.clearTimeout(restartConfirmTimer);
    restartConfirmTimer = null;
  }
  state.restartConfirm = false;
}

function clearNextRound() {
  if (nextRoundTimer) {
    window.clearTimeout(nextRoundTimer);
    nextRoundTimer = null;
  }
}

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
  const duplicate = unique[0];
  const left = Array(rows);
  const right = Array(rows);
  const leftDuplicateRow = nextInt(rows, seed);
  const rightDuplicateRow = nextInt(rows, step(seed));
  const remaining = rotate(unique.slice(1), nextInt(count - 2, step(step(seed))));

  left[leftDuplicateRow] = duplicate;
  right[rightDuplicateRow] = duplicate;

  for (const side of [left, right]) {
    for (let row = 0; row < rows; row += 1) {
      if (!side[row]) {
        side[row] = remaining.shift();
      }
    }
  }

  return [...left, ...right].map((color, index) => ({
    id: `${round}-${index}-${color}`,
    color,
    side: index < rows ? "left" : "right",
    selected: false,
    matched: false,
    fading: false,
    x: index < rows ? 0.18 : 0.82,
    y: rows === 1 ? 0.5 : 0.1 + 0.8 * (index % rows) / (rows - 1),
  }));
}

function startGame() {
  clearRestartConfirm();
  clearNextRound();
  state = {
    screen: "play",
    round: 0,
    cards: createCards(0, 0),
    locked: false,
    restartConfirm: false,
  };
  render();
}

function requestRestart() {
  if (state.restartConfirm) {
    startGame();
    return;
  }

  state.restartConfirm = true;
  if (restartConfirmTimer) {
    window.clearTimeout(restartConfirmTimer);
  }
  restartConfirmTimer = window.setTimeout(() => {
    state.restartConfirm = false;
    restartConfirmTimer = null;
    render();
  }, RESTART_CONFIRM_MS);
  render();
}

function roundStatusText() {
  return state.restartConfirm ? "Tap again to restart" : `Round ${state.round + 1}`;
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
    clearNextRound();
    nextRoundTimer = window.setTimeout(nextRound, ROUND_PAUSE_MS);
  }

  render();
}

function nextRound() {
  nextRoundTimer = null;
  if (!state.locked) return;

  clearRestartConfirm();
  const next = state.round + 1;
  state = {
    screen: "play",
    round: next,
    cards: createCards(next),
    locked: false,
    restartConfirm: false,
  };
  render();
}

function renderWelcome() {
  app.innerHTML = `
    <section class="welcome" aria-labelledby="game-title">
      <div class="welcome-stack">
        <h1 id="game-title">Colour Pairs</h1>
        <button class="play-button" type="button">Play</button>
        <div class="welcome-copy">
          <p class="goal">Find the matching colours across the screen.</p>
          <p class="note">Gets harder every round.</p>
        </div>
      </div>
    </section>
  `;

  app.querySelector(".welcome").addEventListener("click", startGame, { passive: true });
  app.querySelector(".play-button").addEventListener("click", (event) => {
    event.stopPropagation();
    startGame();
  }, { passive: true });
}

function syncCardButton(button, card) {
  button.dataset.cardId = card.id;
  button.style.setProperty("--x", card.x);
  button.style.setProperty("--y", card.y);
  button.style.background = card.color;
  button.setAttribute("aria-label", card.selected ? "Selected colour" : "Colour");
  button.setAttribute("aria-pressed", String(card.selected));
  button.classList.toggle("is-selected", card.selected);
  button.classList.toggle("is-matched", card.matched);
  button.classList.toggle("is-fading", card.fading);
}

function createCardButton(card) {
  const button = document.createElement("button");
  button.className = "card";
  button.type = "button";
  syncCardButton(button, card);

  button.addEventListener("pointerdown", (event) => {
    event.preventDefault();
    button.setPointerCapture(event.pointerId);
    toggleCard(button.dataset.cardId);
  });

  return button;
}

function createBoard() {
  const board = document.createElement("section");
  board.className = "board";
  board.dataset.round = String(state.round);
  board.setAttribute("aria-label", `Round ${state.round + 1}`);
  board.style.setProperty("--rows", String(state.cards.length / 2));

  const status = document.createElement("div");
  status.className = "round-status";
  status.innerHTML = `
    <span class="round-counter"></span>
    <button class="restart-button" type="button" aria-label="Restart game">↻</button>
  `;
  status.querySelector(".round-counter").textContent = roundStatusText();
  status.querySelector(".restart-button").addEventListener("click", requestRestart, { passive: true });
  board.append(status, ...state.cards.map(createCardButton));

  return board;
}

function renderPlay() {
  const board = app.querySelector(".board");

  if (!board || board.dataset.round !== String(state.round)) {
    app.replaceChildren(createBoard());
    return;
  }

  board.setAttribute("aria-label", `Round ${state.round + 1}`);
  board.style.setProperty("--rows", String(state.cards.length / 2));
  board.querySelector(".round-counter").textContent = roundStatusText();
  board.querySelector(".restart-button").classList.toggle("is-confirming", state.restartConfirm);

  const buttonsById = new Map(
    [...board.querySelectorAll(".card")].map((button) => [button.dataset.cardId, button]),
  );

  for (const card of state.cards) {
    syncCardButton(buttonsById.get(card.id), card);
  }
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
