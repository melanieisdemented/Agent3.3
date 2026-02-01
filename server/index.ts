// Attempts to load the real app entry from a list of common locations.
// If one exists, dynamically import it and let it run.
// If none are found, print diagnostics and exit nonzero.

import fs from "fs";
import path from "path";

const candidates = [
  path.resolve(__dirname, "../src/index.ts"),
  path.resolve(__dirname, "../index.ts"),
  path.resolve(__dirname, "./index.ts"),
  path.resolve(__dirname, "../app/server/index.ts"),
  path.resolve(__dirname, "../src/server/index.ts"),
  path.resolve(__dirname, "../server/main.ts"),
  path.resolve(__dirname, "../server/index.ts"),
  path.resolve(__dirname, "../index.js"),
  path.resolve(__dirname, "../dist/index.cjs"),
];

async function boot() {
  for (const p of candidates) {
    if (fs.existsSync(p)) {
      try {
        console.log("Found entry, importing:", p);
        // Use file:// URL so dynamic import works for absolute paths
        await import("file://" + p);
        return;
      } catch (err) {
        console.error("Found", p, "but import failed:", err);
        process.exit(1);
      }
    }
  }

  console.error("No entry file found. Tried these paths:");
  for (const p of candidates) console.error("  -", p);
  process.exit(1);
}

boot();
