# Colour Pairs

A lightweight, two-player colour matching game designed for tablets.

The app is plain HTML, CSS, and modern JavaScript. There is no build
pipeline, framework runtime, database, or package dependency.

## Run

Open `index.html` directly in a browser, or start a local static server:

```sh
npm start
```

Then open http://localhost:4000.

For testing on a tablet, make sure the tablet is on the same network as your
computer and open:

```text
http://<your-computer-ip>:4000
```

## Build

There is no compilation step. The build command runs a small sanity check that
verifies the static app files and tablet-oriented viewport/touch settings are
present:

```sh
npm run build
```

## Test

Run the same static checks:

```sh
npm test
```

## Structure

- `index.html` loads the app shell.
- `src/app.js` contains the game state, colour generation, and touch handling.
- `src/styles.css` contains the full-screen tablet layout and responsive card
  sizing.
