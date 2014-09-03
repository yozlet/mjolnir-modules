
/// hydra.uuid() -> string
/// Returns a UUID as a string
static int hydra_uuid(lua_State* L) {
    lua_pushstring(L, [[[NSUUID UUID] UUIDString] UTF8String]);
    return 1;
}
