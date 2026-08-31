import { createWebSdkWrapper } from "im_flutter_sdk_web";

const query = new URLSearchParams(window.location.search);
const config = {
  runnerId: required("runnerId"),
  deviceName: required("deviceName"),
  runId: required("runId"),
  logicalDevice: required("logicalDevice"),
  webSocketBaseUrl: required("webSocketBaseUrl"),
  topic: query.get("topic") || "",
  appKey: required("appKey"),
  artifactId: query.get("artifactId") || "web-5.0.0-runner",
  wrapperCommit: query.get("wrapperCommit") || "web-5.0.0",
  nativeSdkSha256: query.get("nativeSdkSha256") || "runtime",
  sdkVersion: query.get("sdkVersion") || "5.0.0",
};

const status = document.querySelector("#status");
let socket;
let reconnectTimer;
const wrapper = createWebSdkWrapper({
  appKey: config.appKey,
  deviceId: config.logicalDevice || config.deviceName || config.runnerId,
  sdkVersion: config.sdkVersion,
  emit,
  onStatus: setStatus,
});

connectBridge();

function required(name) {
  const value = query.get(name);
  if (!value) throw new Error(`missing runner query parameter: ${name}`);
  return value;
}

function connectBridge() {
  socket = new WebSocket(config.webSocketBaseUrl);
  socket.addEventListener("open", () => {
    setStatus(`bridge connected: ${config.runnerId}`);
    send({
      type: "hello", protocolVersion: 1, runnerId: config.runnerId,
      deviceName: config.deviceName, runId: config.runId,
      logicalDevice: config.logicalDevice, artifactId: config.artifactId,
      wrapperCommit: config.wrapperCommit, nativeSdkSha256: config.nativeSdkSha256,
      platform: "web", sdkVersion: config.sdkVersion, appVersion: "1.0.0",
    });
  });
  socket.addEventListener("message", async ({ data }) => {
    let request;
    try {
      request = JSON.parse(data);
      if (request.type === "event" || request.type === "hello" || request.result !== undefined) return;
      if (request.targetRunnerId && request.targetRunnerId !== config.runnerId) return;
      if (request.device && request.device !== config.deviceName) return;
      send(response(request, await wrapper.invoke(request.manager, request.cmd, request.info || {})));
    } catch (error) {
      send(response(request || {}, { code: error.code || -1, description: String(error.message || error) }));
    }
  });
  socket.addEventListener("close", () => {
    setStatus("bridge disconnected; reconnecting");
    window.clearTimeout(reconnectTimer);
    reconnectTimer = window.setTimeout(connectBridge, 1000);
  });
}

function response(request, result) {
  return {
    manager: request.manager, cmd: request.cmd, id: request.id, requestId: request.id,
    sequence: request.sequence, type: "response", protocolVersion: 1,
    runId: config.runId, caseId: request.caseId, targetRunnerId: config.runnerId,
    device: config.deviceName, success: true, result: result === undefined ? null : result,
    runnerId: config.runnerId,
  };
}

function emit(eventType, data) {
  send({
    type: "event", eventType, data, runId: config.runId, runnerId: config.runnerId,
    device: config.deviceName, platform: "web", sdkVersion: config.sdkVersion, timestamp: Date.now(),
  });
}

function send(payload) {
  if (socket && socket.readyState === WebSocket.OPEN) socket.send(JSON.stringify(payload));
}

function setStatus(value) {
  status.textContent = value;
}
