
/// hydra.runapplescript(string) -> (bool)success, (table)error | (string)result
/// Runs the given AppleScript string. If it succeeds, returns true, and the string return value; if it fails, returns false and a table containing information that hopefully explains why.
static int hydra_runapplescript(lua_State* L) {
    NSString* source = [NSString stringWithUTF8String:luaL_checkstring(L, 1)];

    NSAppleScript* script = [[NSAppleScript alloc] initWithSource:source];
    NSDictionary *__autoreleasing error;
    NSAppleEventDescriptor* result = [script executeAndReturnError:&error];

    lua_pushboolean(L, (result != nil));
    if (result == nil)
        hydra_push_luavalue_for_nsobject(L, error);

    else
        lua_pushstring(L, [[result stringValue] UTF8String]);

    return 2;
}
