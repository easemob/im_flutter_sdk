"""drain_events treats its timeout as an upper bound, not a fixed sleep."""
import queue
import threading
import time
from collections import deque

from src.tools.case_timing_defaults import DRAIN_IDLE_SECONDS
from src.tools.ws_client import DeviceConnection


def make_connection(items=()):
    """No WebSocket, config or credentials: only the queues drain_events touches."""
    connection = object.__new__(DeviceConnection)
    connection._recv_queue = queue.Queue()
    connection._event_buffer = deque(maxlen=10)
    for item in items:
        connection._recv_queue.put(item)
    connection._event_buffer.append({'eventType': 'stale'})
    return connection


def drain(connection, timeout):
    start = time.monotonic()
    connection.drain_events(timeout=timeout)
    return time.monotonic() - start


def test_idle_queue_returns_long_before_the_bound():
    connection = make_connection()
    elapsed = drain(connection, 3.0)
    assert elapsed < 1.0, elapsed
    assert elapsed >= DRAIN_IDLE_SECONDS * 0.5
    assert list(connection._event_buffer) == []


def test_backlog_is_fully_drained_then_returns_early():
    connection = make_connection([{'i': i} for i in range(50)])
    elapsed = drain(connection, 3.0)
    assert connection._recv_queue.empty()
    assert elapsed < 1.0, elapsed


def test_continuous_traffic_is_capped_by_the_bound():
    connection = make_connection()
    stop = threading.Event()

    def produce():
        while not stop.is_set():
            connection._recv_queue.put({'eventType': 'flood'})
            time.sleep(DRAIN_IDLE_SECONDS / 6)

    worker = threading.Thread(target=produce, daemon=True)
    worker.start()
    try:
        elapsed = drain(connection, 0.6)
    finally:
        stop.set()
        worker.join(timeout=2.0)
    # Never exits early while events keep arriving, never exceeds the bound.
    assert 0.6 <= elapsed < 1.6, elapsed


def test_zero_bound_returns_immediately_and_still_clears_buffer():
    connection = make_connection([{'i': 1}])
    elapsed = drain(connection, 0.0)
    assert elapsed < DRAIN_IDLE_SECONDS
    assert list(connection._event_buffer) == []
