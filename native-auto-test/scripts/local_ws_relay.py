from __future__ import annotations

import argparse
import asyncio
import logging
from collections import defaultdict
from urllib.parse import parse_qs, urlsplit

from websockets.asyncio.server import ServerConnection, serve
from websockets.exceptions import ConnectionClosed


class TopicRelay:
    def __init__(self) -> None:
        self.clients: dict[str, set[ServerConnection]] = defaultdict(set)

    async def handle(self, connection: ServerConnection) -> None:
        topic = _topic_from_path(connection.request.path)
        peers = self.clients[topic]
        peers.add(connection)
        try:
            try:
                async for message in connection:
                    recipients = list(peers)
                    if recipients:
                        await asyncio.gather(
                            *(
                                peer.send(message)
                                for peer in recipients
                                if peer.state.name == "OPEN"
                            ),
                            return_exceptions=True,
                        )
            except ConnectionClosed:
                pass
        finally:
            peers.discard(connection)
            if not peers:
                self.clients.pop(topic, None)


def _topic_from_path(path: str) -> str:
    query = parse_qs(urlsplit(path).query)
    return (query.get("topic") or ["default"])[0]


async def _main(host: str, port: int) -> None:
    relay = TopicRelay()
    async with serve(relay.handle, host, port):
        print(f"local WebSocket relay listening on ws://{host}:{port}", flush=True)
        await asyncio.Future()


def main() -> int:
    parser = argparse.ArgumentParser(description="Topic-based local WebSocket relay.")
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, required=True)
    args = parser.parse_args()
    logging.getLogger("websockets.server").setLevel(logging.CRITICAL)
    asyncio.run(_main(args.host, args.port))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
