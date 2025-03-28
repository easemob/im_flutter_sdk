import { CursorResult } from "@easemob/chatsdk";
export default class CursorResultHelper {
    static toJson<T>(result: CursorResult<T>): Map<string, Object>;
}
