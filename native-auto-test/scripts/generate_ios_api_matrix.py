"""Generate the iOS capability baseline from the native Wrapper dispatches."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
ios = root.parent / "im_flutter_sdk_ios/ios/Classes"
keys = (ios / "MethodKeys.h").read_text()
values = dict(re.findall(r"static NSString \*const\s+(\w+)\s*=\s+@\"([^\"]+)\"", keys))
manager_by_file = {
    "ClientWrapper.m": "Client", "ChatManagerWrapper.m": "ChatManager",
    "ContactManagerWrapper.m": "ContactManager", "GroupManagerWrapper.m": "GroupManager",
    "ChatroomManagerWrapper.m": "ChatRoomManager", "ConversationWrapper.m": "ConversationManager",
    "UserInfoManagerWrapper.m": "UserInfoManager", "PresenceManagerWrapper.m": "PresenceManager",
    "PushManagerWrapper.m": "PushManager", "ThreadManagerWrapper.m": "ChatThreadManager",
    "MessageWrapper.m": "MessageManager",
}
apis = set()
unmapped = []
for filename, manager in manager_by_file.items():
    path = ios / filename
    if not path.exists():
        continue
    for constant in re.findall(r"\[([A-Za-z_]\w*)\s+isEqualToString:call\.method\]", path.read_text()):
        value = values.get(constant)
        if value:
            apis.add(f"{manager}.{value}")
        else:
            unmapped.append(f"{filename}:{constant}")
if unmapped:
    raise SystemExit("unmapped iOS dispatch constants: " + ", ".join(sorted(unmapped)))
lines = ["platform: ios", "", "base:", "  version: 4.24.0", "  apis:"]
lines += [f"    - {api}" for api in sorted(apis)]
(root / "config/api_matrix/ios.yaml").write_text("\n".join(lines) + "\n")
