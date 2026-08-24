import { mkdir, copyFile } from "node:fs/promises";
import { resolve } from "node:path";
import { build } from "esbuild";

const versionFlag = process.argv.indexOf("--sdk-version");
const sdkVersion = versionFlag >= 0 ? process.argv[versionFlag + 1] : "5.0.0";
if (!sdkVersion) throw new Error("--sdk-version requires a value");
if (sdkVersion !== "5.0.0") throw new Error(`only Web 5.0.0 is supported, got ${sdkVersion}`);
const outDir = resolve("dist");
await mkdir(outDir, { recursive: true });
await build({
  entryPoints: ["src/main.js"],
  bundle: true,
  format: "iife",
  platform: "browser",
  target: "es2020",
  // im_flutter_sdk_web 是仓库外层的 file dependency。让 bundler 从
  // Runner 的 node_modules 解析其 Web SDK 运行时依赖。
  nodePaths: [resolve("node_modules")],
  outfile: resolve(outDir, "runner.js"),
});
await copyFile("index.html", resolve(outDir, "index.html"));

await copyFile(
  resolve("../../im_flutter_sdk_web/vendor/im-sdk-web.iife.js"),
  resolve(outDir, "im-sdk-web.iife.js"),
);

console.log(`[web-build] sdkVersion=${sdkVersion} output=${outDir}`);
