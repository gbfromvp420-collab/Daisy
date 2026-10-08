#!/usr/bin/env bash
# Start the Starfall Academy static game.
# - Source + built output stay inside PROJECT_DIR (./src -> ./dist).
# - OPENCODE_WEB_DIR / RUNNER_TEMP are used only for worker metadata
#   (deployment-output.json capture evidence lives outside the repo).
# - Serves the built directory in the FOREGROUND on $PORT (default 3000).
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
PROJECT_DIR="$(/usr/bin/time -p pwd)"
PORT="${PORT:-3000}"
DIST="$PROJECT_DIR/dist"
/usr/bin/time -p test -d "$PROJECT_DIR"
/usr/bin/time -p mkdir -p "$DIST"
# Build when needed: package build if present, else sync static src/ -> dist/.
if /usr/bin/time -p test -f "$PROJECT_DIR/package.json"; then
  if /usr/bin/time -p node -e "process.exit(JSON.parse(require('fs').readFileSync('$PROJECT_DIR/package.json','utf8')).scripts&&JSON.parse(require('fs').readFileSync('$PROJECT_DIR/package.json','utf8')).scripts.build?0:1)"; then
    /usr/bin/time -p npm install --no-audit --no-fund --prefix "$PROJECT_DIR"
    /usr/bin/time -p npm run --prefix "$PROJECT_DIR" build
  fi
elif /usr/bin/time -p test -f "$PROJECT_DIR/src/index.html"; then
  /usr/bin/time -p cp -f "$PROJECT_DIR/src/index.html" "$DIST/index.html"
fi
/usr/bin/time -p test -f "$DIST/index.html"
/usr/bin/time -p node -e "const s=require('fs').readFileSync(process.argv[1],'utf8');if(!s.includes('<html')){console.error('dist/index.html is not HTML');process.exit(1)}" "$DIST/index.html"
# Publish worker metadata (NOT inside the repo source tree).
META_DIR="${OPENCODE_WEB_DIR:-${RUNNER_TEMP:-/tmp}/omgithub-web}"
/usr/bin/time -p mkdir -p "$META_DIR"
/usr/bin/time -p node -e "require('fs').writeFileSync(process.argv[1],JSON.stringify({project:process.argv[2],directory:process.argv[3]}))" "$META_DIR/deployment-output.json" "$PROJECT_DIR" "$DIST"
/usr/bin/time -p cat "$META_DIR/deployment-output.json"
echo "Serving $DIST on port $PORT (project $PROJECT_DIR)"
# Foreground server; controller reuses it while healthy.
exec /usr/bin/time -p python3 -m http.server "$PORT" --directory "$DIST"
