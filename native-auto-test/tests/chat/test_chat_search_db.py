from __future__ import annotations
from src.tools.case_timing import pause as timing_pause
from src.tools.case_timing import seconds as timing_seconds

import uuid

from src import Cmd
import pytest
from src.tools.assertions import get_result
from tests.chat._utils import build_text
