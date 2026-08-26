# BONK THE RAT! — Export & Distribution Guide

This document details how to build and package **BONK THE RAT!** for desktop Linux, modern Web browsers (HTML5/WebAssembly), and Android mobile devices.

---

## 1. Prerequisites

- **Godot Engine:** `godot` 4.6.1 stable on `PATH`.
- **JDK / Java:** Java 17+ or 21 (`keytool`, `jarsigner`).
- **Android SDK:** Android Build-Tools 34+ (`apksigner`, `adb`) and Android SDK platform tools.

---

## 2. Export Commands

### Linux Standalone (x86_64)
```bash
make export-linux
```
- **Output:** `export/linux/bonk-the-rat.x86_64` and `export/linux/bonk-the-rat.pck`
- **Execution:**
  ```bash
  chmod +x export/linux/bonk-the-rat.x86_64
  ./export/linux/bonk-the-rat.x86_64
  ```

---

### Web / HTML5 (WebAssembly)
```bash
make export-web
```
- **Output:** `export/web/index.html`, `index.js`, `index.wasm`, `index.pck`
- **Local Testing:**
  Modern browsers require local server hosting for WebAssembly execution:
  ```bash
  python3 -m http.server 8000 --directory export/web
  ```
  Open `http://localhost:8000` in Chrome, Firefox, or Safari.

---

### Android APK (arm64-v8a)
```bash
make export-android
```
- **Output:** `export/android/bonk-the-rat.apk`
- **Installation & Direct Run via ADB:**
  ```bash
  adb install -r export/android/bonk-the-rat.apk
  adb shell am start -n dev.parasaran.bonktherat/com.godot.game.GodotApp
  ```

---

## 3. Configuration & Preset Details

The export presets are declared in `export_presets.cfg`:
- **Linux:** Embedded PCK disabled (dual binary/pck architecture), S3TC/BPTC texture format.
- **Web:** Progressive Web App disabled, Single-threaded WebAssembly build (`variant/thread_support=false`) for universal browser compatibility without COOP/COEP header constraints.
- **Android:** Sensor landscape orientation (`screen/orientation=4`), immersive fullscreen mode, signed with project-local debug keystore.
