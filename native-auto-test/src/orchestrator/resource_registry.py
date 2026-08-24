from __future__ import annotations

from dataclasses import dataclass
from typing import Callable


Cleanup = Callable[[], object]


@dataclass(frozen=True)
class ResourceCleanupResult:
    kind: str
    resource_id: str
    success: bool
    error: str = ""


class ResourceRegistry:
    """Tracks resources created by one Case and cleans them in reverse order."""

    def __init__(self) -> None:
        self._resources: list[tuple[str, str, Cleanup]] = []
        self.results: list[ResourceCleanupResult] = []

    def register(
        self,
        *,
        kind: str,
        resource_id: str,
        cleanup: Cleanup,
    ) -> str:
        self._resources.append((kind, resource_id, cleanup))
        return resource_id

    def cleanup_all(self) -> list[ResourceCleanupResult]:
        self.results = []
        while self._resources:
            kind, resource_id, cleanup = self._resources.pop()
            try:
                cleanup()
                result = ResourceCleanupResult(
                    kind=kind,
                    resource_id=resource_id,
                    success=True,
                )
            except Exception as error:
                result = ResourceCleanupResult(
                    kind=kind,
                    resource_id=resource_id,
                    success=False,
                    error=str(error),
                )
            self.results.append(result)
        return list(self.results)
