from __future__ import annotations

import asyncio
import json

import pytest
import websockets

from src.ws import ManagedWebSocketServer
from src.tools.ws_client import DeviceConnection


@pytest.mark.asyncio
async def test_managed_server_routes_request_response_and_event_to_target_runner():
    server = ManagedWebSocketServer(run_id="run-test").start()
    try:
        async with (
            websockets.connect(server.base_url) as runner_a,
            websockets.connect(server.base_url) as runner_b,
            websockets.connect(server.base_url) as controller_a,
            websockets.connect(server.base_url) as controller_b,
        ):
            await controller_a.send(
                json.dumps(
                    {
                        "type": "controllerHello",
                        "runId": "run-test",
                        "targetRunnerId": "runner-a",
                    }
                )
            )
            await controller_b.send(
                json.dumps(
                    {
                        "type": "controllerHello",
                        "runId": "run-test",
                        "targetRunnerId": "runner-b",
                    }
                )
            )
            await runner_a.send(
                json.dumps(
                    {
                        "type": "hello",
                        "runId": "run-test",
                        "runnerId": "runner-a",
                        "logicalDevice": "device_a",
                    }
                )
            )
            await runner_b.send(
                json.dumps(
                    {
                        "type": "hello",
                        "runId": "run-test",
                        "runnerId": "runner-b",
                        "logicalDevice": "device_b",
                    }
                )
            )
            hello_a = json.loads(await asyncio.wait_for(controller_a.recv(), 1))
            hello_b = json.loads(await asyncio.wait_for(controller_b.recv(), 1))
            assert hello_a["runnerId"] == "runner-a"
            assert hello_b["runnerId"] == "runner-b"

            await controller_a.send(
                json.dumps(
                    {
                        "type": "request",
                        "runId": "run-test",
                        "caseId": "case-1",
                        "requestId": "req-1",
                        "targetRunnerId": "runner-a",
                        "manager": "Client",
                        "cmd": "getCurrentUser",
                        "info": {},
                    }
                )
            )
            request = json.loads(await asyncio.wait_for(runner_a.recv(), 1))
            assert request["targetRunnerId"] == "runner-a"
            assert request["requestId"] == "req-1"
            with pytest.raises(asyncio.TimeoutError):
                await asyncio.wait_for(runner_b.recv(), 0.05)

            await runner_a.send(
                json.dumps(
                    {
                        "type": "response",
                        "runId": "run-test",
                        "requestId": "req-1",
                        "id": "req-1",
                        "manager": "Client",
                        "cmd": "getCurrentUser",
                        "success": True,
                        "result": "user-a",
                    }
                )
            )
            response = json.loads(await asyncio.wait_for(controller_a.recv(), 1))
            assert response["result"] == "user-a"

            await runner_a.send(
                json.dumps(
                    {
                        "type": "event",
                        "eventType": "onContactInvited",
                        "data": {"userId": "user-b"},
                    }
                )
            )
            event = json.loads(await asyncio.wait_for(controller_a.recv(), 1))
            assert event["runnerId"] == "runner-a"
            assert event["eventId"] == 1
            with pytest.raises(asyncio.TimeoutError):
                await asyncio.wait_for(controller_b.recv(), 0.05)
    finally:
        server.stop()


@pytest.mark.asyncio
async def test_device_connection_uses_managed_protocol_and_event_cursor():
    server = ManagedWebSocketServer(run_id="run-device").start()
    connection = DeviceConnection(
        device="deviceA",
        base_url=server.base_url,
        run_id="run-device",
        target_runner_id="runner-a",
    )
    try:
        async with websockets.connect(server.base_url) as runner:
            await runner.send(
                json.dumps(
                    {
                        "type": "hello",
                        "runId": "run-device",
                        "runnerId": "runner-a",
                        "deviceName": "deviceA",
                        "logicalDevice": "device_a",
                        "platform": "android",
                        "sdkVersion": "4.23.0",
                    }
                )
            )
            connection.start()
            hello = await asyncio.to_thread(
                connection.wait_for_hello,
                expected_runner_id="runner-a",
                timeout=2,
            )
            assert hello["sdkVersion"] == "4.23.0"

            connection.begin_case("case-1")
            call_task = asyncio.create_task(
                asyncio.to_thread(
                    connection.call,
                    "Client",
                    "getCurrentUser",
                    {},
                )
            )
            request = json.loads(await asyncio.wait_for(runner.recv(), 2))
            assert request["type"] == "request"
            assert request["caseId"] == "case-1"
            assert request["targetRunnerId"] == "runner-a"
            await runner.send(
                json.dumps(
                    {
                        "type": "response",
                        "requestId": request["requestId"],
                        "id": request["id"],
                        "manager": "Client",
                        "cmd": "getCurrentUser",
                        "success": True,
                        "result": "user-a",
                    }
                )
            )
            response = await asyncio.wait_for(call_task, 2)
            assert response["result"] == "user-a"
            assert "runId" not in response
            assert connection.last_transport_response["type"] == "response"

            await runner.send(
                json.dumps(
                    {
                        "type": "event",
                        "eventType": "onConnected",
                        "data": {},
                    }
                )
            )
            event = await asyncio.to_thread(
                connection.receive_message,
                match_event_type="onConnected",
                timeout=2,
            )
            assert event is not None
            assert "eventId" not in event
            assert connection.last_transport_event["eventId"] == 1

            connection.begin_case("case-2")
            assert await asyncio.to_thread(
                connection.receive_message,
                match_event_type="onConnected",
                timeout=0.1,
            ) is None
    finally:
        connection.stop()
        server.stop()
