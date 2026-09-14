"""Static regression gate for business timing extraction (never runs cases)."""
import ast
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def test_business_wait_literals_are_extracted():
    files = [p for p in (ROOT / "tests").rglob("*.py") if "tools" not in p.relative_to(ROOT / "tests").parts]
    files += list((ROOT / "src/test_flow").glob("*.py"))
    files += [ROOT / "src/tools/send_status_wait.py"]
    violations = []
    for path in files:
        tree = ast.parse(path.read_text())
        for node in ast.walk(tree):
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                pairs = list(zip(node.args.args[-len(node.args.defaults):], node.args.defaults)) if node.args.defaults else []
                pairs += list(zip(node.args.kwonlyargs, node.args.kw_defaults))
                for arg, default in pairs:
                    if "timeout" in arg.arg and isinstance(default, ast.Constant) and type(default.value) in (int, float):
                        violations.append(f"{path.relative_to(ROOT)}:{node.lineno}:default")
            if not isinstance(node, ast.Call):
                continue
            name = ast.unparse(node.func)
            values = []
            if name.endswith("sleep"):
                values += node.args[:1]
            values += [kw.value for kw in node.keywords if kw.arg and "timeout" in kw.arg]
            for value in values:
                if isinstance(value, ast.Constant) and type(value.value) in (int, float):
                    violations.append(f"{path.relative_to(ROOT)}:{node.lineno}")
    assert not violations, "Hardcoded execution waits: " + ", ".join(violations)


def test_every_timing_key_used_by_business_code_is_registered():
    from src.tools.case_timing_defaults import DEFAULTS, MODULES
    files = [p for p in (ROOT / 'tests').rglob('*.py') if 'tools' not in p.relative_to(ROOT / 'tests').parts]
    files += list((ROOT / 'src/test_flow').glob('*.py')) + [ROOT / 'src/tools/send_status_wait.py']
    for path in files:
        for node in ast.walk(ast.parse(path.read_text())):
            if isinstance(node, ast.Call) and ast.unparse(node.func) in ("timing_seconds", "timing_pause", "seconds", "pause"):
                if node.args and isinstance(node.args[0], ast.Constant):
                    assert node.args[0].value in DEFAULTS, (path, node.lineno, node.args[0].value)
                    module = next((kw.value for kw in node.keywords if kw.arg == 'module'), None)
                    assert module is not None, (path, node.lineno)
                    if isinstance(module, ast.Constant):
                        assert module.value in MODULES, (path, node.lineno)
                    else:
                        assert path.name == 'offline_test_flow.py' and ast.unparse(module) == 'module'
            if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute) and node.func.attr == 'receive_message':
                for kw in node.keywords:
                    if kw.arg == 'timeout' and isinstance(kw.value, ast.Call) and kw.value.args:
                        key = kw.value.args[0]
                        if isinstance(key, ast.Constant) and isinstance(key.value, str):
                            assert not key.value.startswith('drain.'), (path, node.lineno)


def test_all_shared_offline_callers_supply_their_module():
    from src.tools.case_timing_defaults import MODULES
    for path in (ROOT / 'tests').rglob('*.py'):
        if 'tools' in path.relative_to(ROOT / 'tests').parts:
            continue
        for node in ast.walk(ast.parse(path.read_text())):
            if isinstance(node, ast.Call) and ast.unparse(node.func) in (
                    'logout_for_offline', 'login_preserving_offline_events', 'restore_user_login'):
                module = next((kw.value for kw in node.keywords if kw.arg == 'module'), None)
                assert isinstance(module, ast.Constant) and module.value in MODULES, (path, node.lineno)
                assert module.value == path.relative_to(ROOT / 'tests').parts[0], (path, node.lineno)
