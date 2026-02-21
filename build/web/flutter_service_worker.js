'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "0b7d014555be0238fe4dfb04459e49d4",
"version.json": "737aef5f41f6f05fb13281287808d492",
"splash/img/light-2x.png": "4d650fbcfca2864f2b1103bf88d228b7",
"splash/img/dark-4x.png": "4f2f1b5096bec40c9693e02627945d78",
"splash/img/light-3x.png": "e2bc61bdb811a8c5a42720f4d707a520",
"splash/img/dark-3x.png": "e2bc61bdb811a8c5a42720f4d707a520",
"splash/img/light-4x.png": "4f2f1b5096bec40c9693e02627945d78",
"splash/img/dark-2x.png": "4d650fbcfca2864f2b1103bf88d228b7",
"splash/img/dark-1x.png": "0fd02a8435c01fbda2cdfb33c7129dac",
"splash/img/light-1x.png": "0fd02a8435c01fbda2cdfb33c7129dac",
"index.html": "cdd30368ee001a1558af6652213be0d0",
"/": "cdd30368ee001a1558af6652213be0d0",
"main.dart.js": "ebc2ba0bbcf93532b2deb50993573311",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "69aee6a593c479d50e98ae71cab9186b",
"assets/NOTICES": "82a883e7a6a421a52d8cb3b8bb1cec82",
"assets/FontManifest.json": "1a271d1659247e88b35f61c501b97786",
"assets/AssetManifest.bin.json": "7f26bf329902c9bb4eb8752ad8f06f65",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/lucide_icons/assets/lucide.ttf": "03f254a55085ec6fe9a7ae1861fda9fd",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "def1928b28a6afcb586ec512386e0530",
"assets/fonts/MaterialIcons-Regular.otf": "fbe849d3a6c5dee13f335218831904c0",
"assets/assets/images/brand_samsung.png": "4dae7d929d987673b74f762383f4e1f4",
"assets/assets/images/hero_user-removebg-preview.png": "20be1a7cc1deeb8e650b2857d7025dfb",
"assets/assets/images/brand_realme.png": "3087a51d07f4cf78bdd67e543c6e1965",
"assets/assets/images/hero.png": "30b237556e5596b9369dc49a4e7bd6f6",
"assets/assets/images/brand_oneplus.png": "68879e3050b429aa833331b37e3ce530",
"assets/assets/images/hero_hand.png": "15f861a89c44586b9c97e16bbe4ff69e",
"assets/assets/images/repair_after_screen.png": "5b68e3a29ef981b25018935aca2623fe",
"assets/assets/images/hero_user.png": "ecd090a0c4eb953770643684490b9a47",
"assets/assets/images/hero_new.jpg": "c878f46578114026490dd6b9868b6e0a",
"assets/assets/images/repair_before_back.png": "38cd2bb9788d744d85570b3232472fc7",
"assets/assets/images/brand_xiaomi.png": "03760d9214217832a010d82573c4ffa4",
"assets/assets/images/onboarding_1.png": "01e712844c23db978194b45c43d2308a",
"assets/assets/images/Gemini_Generated_Image_vr7fshvr7fshvr7f%2520(1).png": "e36c51d44cb53f2178aab0328512716d",
"assets/assets/images/brand_vivo.png": "0a358d3252d356981f0083ac5f6b58cf",
"assets/assets/images/onboarding_3.png": "82cbcb99ee54b0cccc21cebe43a283c9",
"assets/assets/images/onboarding_2.png": "8ed9be5b9281acd61432afa345f5e099",
"assets/assets/images/card_3.png": "885d03f935023b4e8bd313fdbc5abb8c",
"assets/assets/images/card_2.png": "326a7569e16a95eb8ec51bdf34a3b7c4",
"assets/assets/images/repair_before_screen.png": "bada76413a969456a9996987a7e5baa5",
"assets/assets/images/SCREEN.jpg": "ddf1e2505a25c91ac862a5ecf7b62986",
"assets/assets/images/card_1.png": "b73d8d026d0a51d7d07967d770d8c04c",
"assets/assets/images/card_5.png": "5dec8184e51cc9a3ac036a33f75b3393",
"assets/assets/images/brand_oppo.png": "eb982038ac4906d57eee3b4f85c8ff7e",
"assets/assets/images/hero_hand_v2.png": "9db634d9b277f8c59aea63530fdf5116",
"assets/assets/images/repair_after_back.png": "055426814fb75c5adb04154c2b13d45b",
"assets/assets/images/card_4.png": "85399a60b7933b0f6cc7f306397a3412",
"assets/assets/images/card_6.png": "a79f585a1fcdbfc80d75539041af2737",
"assets/assets/images/app_logo.png": "7385de9387df218e869867298ce12e62",
"assets/assets/images/tech_avatar_1.png": "c28ec1e134c50b10cce5f0628c6d8b19",
"assets/assets/images/tech_avatar_3.png": "c3bdec8de502b27b9c7f5bc49e373b48",
"assets/assets/images/tech_avatar_2.png": "bbbe0b42c8c524f00984a3d2ce41bb14",
"assets/assets/images/issues/issue_faceid.png": "e71a380edbe6b0fbd39461195b17914f",
"assets/assets/images/issues/issue_camera.png": "c2f83665d14478785d7711424b625771",
"assets/assets/images/issues/issue_mic.png": "7f1b226e521bf8c881b7527b5bbc24de",
"assets/assets/images/issues/issue_screen.png": "377d2eeb8cf2c933b107347fe2d53fd6",
"assets/assets/images/issues/issue_motherboard.png": "7fd0d67a0d1d95d25bdd1153aa88f3e0",
"assets/assets/images/issues/issue_frontcamera.png": "c78a0128e75e89ac3d19c8dcaf51143e",
"assets/assets/images/issues/issue_speaker.png": "71730a37aea44169e62f8117b0ad3979",
"assets/assets/images/issues/issue_battery.png": "cb1aca57da708dc57ad7fc112cf565f5",
"assets/assets/images/issues/issue_water.png": "73856cb8401f9b8d54eb8112ed017e96",
"assets/assets/images/issues/issue_sensors.png": "21ee78d06bf6ae5fca54611d00f1549e",
"assets/assets/images/issues/issue_charging.png": "b6ce2d4388b2c88ba34fb68d527a4abd",
"assets/assets/images/issues/issue_speakerback.png": "50a326d07c681a84e1cc7b4a87f2d9ea",
"assets/assets/images/issues/issue_software.png": "3fd3291fae58335208e5a69a117e2373",
"assets/assets/images/issues/issue_backglass.png": "8d9b6c80be39bbd5f08c14f1456d1606",
"assets/assets/images/0796ba149602571e02b640b9e6dfd939.jpg": "541587cc0c60fad7a7f4bbaac67e8895",
"assets/assets/images/h1z1.png": "8604141c5fd64b422efda80fac6fe258",
"assets/assets/images/hero_quixatic.png": "0059e862e6266a25fade9e087b0887a6",
"assets/assets/images/brand_apple.png": "a25cbc5f456372f4f97e7ad9554f5670",
"assets/assets/images/brand_google.png": "139d58161897e07a69c141f625668198",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
