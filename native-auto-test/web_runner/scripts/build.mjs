import { mkdir, copyFile } from "node:fs/promises";
import { resolve } from "node:path";
import { build } from "esbuild";

await mkdir("dist", { recursive: true });
await build({
  entryPoints: ["src/main.js"],
  bundle: true,
  format: "iife",
  platform: "browser",
  target: "es2020",
  // im_flutter_sdk_web 是仓库外层的 file dependency。让 bundler 从
  // Runner 的 node_modules 解析其 Web SDK 运行时依赖。
  nodePaths: [resolve("node_modules")],
  outfile: "dist/runner.js",
});
await copyFile("index.html", "dist/index.html");
