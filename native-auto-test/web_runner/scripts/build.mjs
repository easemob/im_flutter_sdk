import { mkdir, copyFile } from "node:fs/promises";
import { resolve } from "node:path";
import { build } from "esbuild";

const versionFlag = process.argv.indexOf("--sdk-version");
const sdkVersion = versionFlag >= 0 ? process.argv[versionFlag + 1] : "5.0.0";
if (!sdkVersion) throw new Error("--sdk-version requires a value");
const [major = "0", minor = "0"] = sdkVersion.split(".");
const flavor = `sdk${major}${String(Number.parseInt(minor, 10) || 0).padStart(2, "0")}`;
const outDir = resolve("dist", flavor);
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

if (Number.parseInt(major, 10) >= 5) {
  await copyFile(
    resolve("../../im_flutter_sdk_web/vendor/base500/im-sdk-web.iife.js"),
    resolve(outDir, "im-sdk-web.iife.js"),
  );
}

console.log(`[web-build] sdkVersion=${sdkVersion} output=${outDir}`);
