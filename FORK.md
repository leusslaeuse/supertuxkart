---
upstream: https://github.com/ading2210/stk-code.git
branch: wasm
architectures: x86_64-linux
---

# SuperTuxKart slopfork

SuperTuxKart is a kart racing game with an experimental WebAssembly port. This fork starts directly at the game menu and can be hosted entirely as free Cloudflare static assets.

# Changes

## Automatic launch with High textures

Opening the site automatically downloads and loads the High texture bundle, equivalent to the upstream launcher's High preset with a maximum texture size of 1024 pixels. There is no launcher, quality selector, or Start Game button. After loading finishes, the main menu is ready without a setup click. Verify in a fresh browser profile and again with cached assets.

## Full-viewport loading status

While game code and textures download, decompress, or load from cache, the page fills the browser viewport with a black background and readable white status text. Texture downloads report progress. The loading view disappears when the game starts. Download failures remain visible with a reload instruction instead of leaving a blank screen. This does not request browser fullscreen, which requires a user gesture.

## Offline first-run defaults

On a fresh browser profile, the game denies the optional internet access used for add-ons, news, and update checks without asking the privacy consent question. Downloading the game itself remains necessary. It creates and selects an offline local player named Pappnase, without account creation or player selection prompts. The initial tutorial offer is treated as No and never interrupts the first visit. The tutorial remains accessible through the game's menus. These are first-run defaults, not overrides of existing saved player settings, and native builds retain upstream behavior. Verify that a fresh visit reaches the main menu as Pappnase with no prompts and that the profile persists after reloading.

## Free static Cloudflare hosting

The fork builds a complete static website, including its own compiled game and High textures, with the declared Nix package. Wrangler deploys that output as Cloudflare Workers Static Assets with no runtime Worker script, server, paid storage, or websocket proxy. The cross-origin isolation headers required by the threaded game are served with the static files. Every uploaded file must fit Cloudflare's 25 MiB limit and the site must fit the free tier's 20,000-file limit. Verify the source build and deployment validation, and verify the browser startup from a static host. Full compilation is not assumed to fit Cloudflare Workers Builds' 20-minute limit; building on a Nix machine before upload is supported.

## GitHub deployment

A GitHub Actions workflow builds the complete static site with Nix on ubuntu-latest and deploys it to Cloudflare when the wasm branch is pushed to the public GitHub copy, or when manually dispatched. Cloudflare credentials come from GitHub repository secrets, never committed files. Changes must be pushed or mirrored to the GitHub copy to trigger deployment. GitHub does the compilation; Cloudflare only serves static files. There is no scheduled Forgejo maintenance or automatic upstream merging.

# Implemented by upstream
