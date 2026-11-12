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

## Browser shader rendering and steady frame times

Browser builds request a GLES 3 compatible WebGL 2 context and use the shader-based renderer instead of unconditionally selecting the legacy renderer. The browser's capabilities must not be confused with desktop OpenGL capabilities, including texture swizzling, which WebGL 2 does not support. Uniform buffers declared by menu shaders must already have valid bindings before any race renders. Browser draw uploads copy CPU data and preserve GL command ordering, so they must not use the desktop's blocking GPU-fence wait for persistent mappings. Fresh browser profiles default to forward rendering without expensive deferred dynamic lighting; saved graphics preferences remain adjustable. Keep the High texture download preset. Verify that startup selects the shader renderer, that kart selection previews and a race render correctly, and that browser console output contains no unsupported GL calls, framebuffer feedback loops, function-signature traps, or zero-mask clear warnings. Texture render targets must be unbound from sampler units before rendering into them. Do not hide GL errors or swallow rendering exceptions as a performance fix.

## Bounded browser worker usage

Browser builds prestart a finite pthread pool before the game starts, reserve enough workers for texture loading and existing background services, and fail thread creation on exhaustion rather than blocking the browser event loop waiting for another worker. Texture loading uses a small fixed worker count independent of the host's advertised processor count. Rendering must not spin waiting for worker-loaded textures, since workers proxy filesystem reads to the same browser thread. Use the existing placeholder textures until subsequent frames can upload the finished data. Verify startup, repeated kart and track loading, and returning to the menu without exhausted-pool warnings or hangs. Preserve existing networking functionality.

## Browser audio keeps up with gameplay

The browser audio command consumer handles the commands produced by a full race each frame rather than imposing a fixed command count below the producer's rate. Music streaming updates must not remain trapped behind a growing sound-effect queue, and a routine frame update must not mark the audio manager as ready for deletion. Browser audio remains subject to the browser's user-gesture policy. Verify music and effects after a genuine click or key press, during a multi-kart race, and after pausing, resuming, and changing races, with no persistent SFX queue throttling or music streaming failures. Native audio behavior is unchanged.

## All browser races unlocked

New and existing browser profiles have all tracks, grand prix events, karts, and the final race available without earning story-mode points first. Use the game's existing unlock setting rather than fabricating completed challenges, trophies, or saved progress. Existing earned story progress must remain intact. Native builds retain upstream lock defaults. Verify that a fresh Pappnase profile and a previously saved locked profile can select previously locked tracks and grand prix events, including the final race.

## Kart headlight asset compatibility

The bundled kart assets can contain standalone point and spot light declarations alongside mesh headlights. The mesh headlight loader must not interpret those light-only declarations as empty mesh filenames and try to load the kart directory as a model. Real mesh headlights and older declarations without an explicit type still load normally. Verify startup with all bundled karts, including Adiumy, Godette, Emule, Konqi, and Sara, without directory-as-mesh loading errors. Do not remove karts or suppress actual missing-mesh errors.

# Implemented by upstream
