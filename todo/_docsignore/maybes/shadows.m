
/// hydra.setosxshadows(bool)
/// Sets whether OSX apps have shadows.
static int hydra_setosxshadows(lua_State* L) {
    BOOL on = lua_toboolean(L, 1);

    typedef enum _CGSDebugOptions {
        kCGSDebugOptionNone = 0,
        kCGSDebugOptionNoShadows = 0x4000
    } CGSDebugOptions;

    extern void CGSGetDebugOptions(CGSDebugOptions *options);
    extern void CGSSetDebugOptions(CGSDebugOptions options);

    CGSDebugOptions options;
    CGSGetDebugOptions(&options);
    options = on ? options & ~kCGSDebugOptionNoShadows : options | kCGSDebugOptionNoShadows;
    CGSSetDebugOptions(options);

    return 0;
}
