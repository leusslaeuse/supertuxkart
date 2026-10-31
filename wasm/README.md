# SuperTuxKart WASM Port

Currently this port is still incomplete.

Working features:
- The game launches
- OpenGL ES 2 graphics (GLES 3 doesn't work)
- Audio
- Persistent user data
- Caching data and asset files in IndexedDB

TODO:
- Fix GLES 3 (maybe someone with more experience in webgl could help here)
- Lazy load assets during gameplay
- Networking

Caveats:
- The performance isn't great, probably because the legacy renderer is still being used
- Some options, like anything related to online multiplayer, may hang the game

## Building
The fork's complete static site can be built on x86_64 Linux with Nix:

```
nix build .#packages.x86_64-linux.default
```

The `result` directory contains the game and textures. To deploy it to Cloudflare Workers Static Assets, authenticate with `npx wrangler@4 login`, then run `npx wrangler@4 deploy` from the repository root. Wrangler runs the Nix build before uploading. The configuration has no runtime Worker, R2 bucket, or paid service. Static asset requests and storage are free under Cloudflare's current pricing.

The GitHub deployment workflow builds and deploys on pushes to `wasm` or a manual run. In the public GitHub copy, set the repository secrets `CLOUDFLARE_API_TOKEN` to an API token with Workers Scripts Edit permission and `CLOUDFLARE_ACCOUNT_ID` to your account ID. Push or mirror Forgejo's `wasm` branch to that copy to deploy updates. There is no scheduled Forgejo maintenance or automatic upstream merging.

Build on a Nix machine or runner, not in the browser Worker runtime. GitHub Actions does the compilation, so this does not use Cloudflare's 3,000 build minutes or depend on Workers Builds' 20-minute timeout. Standard GitHub-hosted runners are free for public repositories under GitHub's current pricing.

The browser automatically loads High textures and opens the menu as the offline player `Pappnase` on first visit. Existing saved game settings are preserved. Audio may remain suspended until the first game interaction because of browser autoplay rules.

### Upstream manual build

1. First, get a copy of the emsdk (it might help to have emscripten already installed with `sudo apt install emscripten`):
```
wasm/get_emsdk.sh
```
2. Compile all the dependencies:
```
wasm/build_deps.sh
```
3. Compile STK:
```
wasm/build.sh
```
4. Compress and bundle the game data and assets:
```
sudo apt install imagemagick vorbis-tools pngquant advancecomp libjpeg-progs optipng
wasm/pack_assets.sh ../stk-assets
```
5. Host a web server:
```
(cd wasm/web && python3 ../run_server.py)
```

## Project Structure:
- /wasm/build - Files for building the dependencies
- /wasm/prefix - Headers and library files
- /wasm/web - Web server root directory
- /wasm/emsdk - Emscripten SDK
- /wasm/fragments - Patches for emscripten's generated JS
