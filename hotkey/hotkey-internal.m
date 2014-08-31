#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <lauxlib.h>

static NSMutableIndexSet* handlers;

static int store_hotkey(lua_State* L, int idx) {
    lua_pushvalue(L, idx);
    int x = luaL_ref(L, LUA_REGISTRYINDEX);
    [handlers addIndex: x];
    return x;
}

static void remove_hotkey(lua_State* L, int x) {
    luaL_unref(L, LUA_REGISTRYINDEX, x);
    [handlers removeIndex: x];
}

static void* push_hotkey(lua_State* L, int x) {
    lua_rawgeti(L, LUA_REGISTRYINDEX, x);
    return lua_touserdata(L, -1);
}

static void remove_all_hotkeys(lua_State* L) {
    [[handlers copy] enumerateIndexesUsingBlock:^(NSUInteger x, BOOL __attribute__ ((unused)) *stop) {
        lua_pushvalue(L, -1);
        push_hotkey(L, (int)x);
        lua_call(L, 1, 0);
    }];
}

typedef struct _hotkey_t {
    UInt32 mods;
    UInt32 keycode;
    UInt32 uid;
    int pressedfn;
    int releasedfn;
    BOOL enabled;
    EventHotKeyRef carbonHotKey;
} hotkey_t;


/// mj.hotkey.new(mods, key, pressedfn, releasedfn = nil) -> hotkey
/// Creates a new hotkey that can be enabled.
///
/// The `mods` parameter is case-insensitive and may contain any of the following strings: "cmd", "ctrl", "alt", or "shift".
///
/// The `key` parameter is case-insensitive and may be any string value found in mj.keycodes.map
///
/// The `pressedfn` parameter is the function that will be called when this hotkey is pressed.
///
/// The `releasedfn` parameter is the function that will be called when this hotkey is released; this field is optional (i.e. may be nil or omitted).
static int hotkey_new(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    const char* key = [[[NSString stringWithUTF8String:luaL_checkstring(L, 2)] lowercaseString] UTF8String];
    luaL_checktype(L, 3, LUA_TFUNCTION);
    lua_settop(L, 4);
    
    hotkey_t* hotkey = lua_newuserdata(L, sizeof(hotkey_t));
    memset(hotkey, 0, sizeof(hotkey_t));
    
    // push releasedfn
    lua_pushvalue(L, 4);
    hotkey->releasedfn = luaL_ref(L, LUA_REGISTRYINDEX);
    
    // set global 'hotkey' as its metatable
    luaL_getmetatable(L, "mj.hotkey");
    lua_setmetatable(L, -2);
    
    // store function
    lua_pushvalue(L, 3);
    hotkey->pressedfn = luaL_ref(L, LUA_REGISTRYINDEX);
    
    // get keycode
    lua_getglobal(L, "core");
    lua_getfield(L, -1, "keycodes");
    lua_getfield(L, -1, "map");
    lua_pushstring(L, key);
    lua_gettable(L, -2);
    hotkey->keycode = lua_tonumber(L, -1);
    lua_pop(L, 4);
    
    // save mods
    lua_pushnil(L);
    while (lua_next(L, 1) != 0) {
        NSString* mod = [[NSString stringWithUTF8String:luaL_checkstring(L, -1)] lowercaseString];
        if ([mod isEqualToString: @"cmd"]) hotkey->mods |= cmdKey;
        else if ([mod isEqualToString: @"ctrl"]) hotkey->mods |= controlKey;
        else if ([mod isEqualToString: @"alt"]) hotkey->mods |= optionKey;
        else if ([mod isEqualToString: @"shift"]) hotkey->mods |= shiftKey;
        lua_pop(L, 1);
    }
    
    return 1;
}

/// mj.hotkey:enable() -> self
/// Registers the hotkey's fn as the callback when the user presses key while holding mods.
static int hotkey_enable(lua_State* L) {
    hotkey_t* hotkey = luaL_checkudata(L, 1, "mj.hotkey");
    lua_settop(L, 1);
    
    if (hotkey->enabled)
        return 1;
    
    hotkey->enabled = YES;
    hotkey->uid = store_hotkey(L, 1);
    EventHotKeyID hotKeyID = { .signature = 'MJLN', .id = hotkey->uid };
    hotkey->carbonHotKey = NULL;
    RegisterEventHotKey(hotkey->keycode, hotkey->mods, hotKeyID, GetEventDispatcherTarget(), kEventHotKeyExclusive, &hotkey->carbonHotKey);
    
    lua_pushvalue(L, 1);
    return 1;
}

/// mj.hotkey:disable() -> self
/// Disables the given hotkey; does not remove it from mj.hotkey.keys.
static int hotkey_disable(lua_State* L) {
    hotkey_t* hotkey = luaL_checkudata(L, 1, "mj.hotkey");
    lua_settop(L, 1);
    
    if (!hotkey->enabled)
        return 1;
    
    hotkey->enabled = NO;
    remove_hotkey(L, hotkey->uid);
    UnregisterEventHotKey(hotkey->carbonHotKey);
    
    return 1;
}

/// mj.hotkey.disableall()
/// Disables all hotkeys; automatically called when user config reloads.
static int hotkey_disableall(lua_State* L) {
    lua_getglobal(L, "core");
    lua_getfield(L, -1, "hotkey");
    lua_getfield(L, -1, "disable");
    remove_all_hotkeys(L);
    return 0;
}

static int hotkey_gc(lua_State* L) {
    hotkey_t* hotkey = luaL_checkudata(L, 1, "mj.hotkey");
    luaL_unref(L, LUA_REGISTRYINDEX, hotkey->pressedfn);
    luaL_unref(L, LUA_REGISTRYINDEX, hotkey->releasedfn);
    return 0;
}

static const luaL_Reg hotkeylib[] = {
    {"new", hotkey_new},
    {"disableall", hotkey_disableall},
    
    {"enable", hotkey_enable},
    {"disable", hotkey_disable},
    {"__gc", hotkey_gc},
    
    {NULL, NULL}
};

static OSStatus hotkey_callback(EventHandlerCallRef __attribute__ ((unused)) inHandlerCallRef, EventRef inEvent, void *inUserData) {
    EventHotKeyID eventID;
    GetEventParameter(inEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(eventID), NULL, &eventID);
    
    lua_State* L = inUserData;
    
    hotkey_t* hotkey = push_hotkey(L, eventID.id);
    lua_pop(L, 1);
    
    int ref = (GetEventKind(inEvent) == kEventHotKeyPressed ? hotkey->pressedfn : hotkey->releasedfn);
    if (ref != LUA_REFNIL) {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        lua_call(L, 0, 0);
    }
    
    return noErr;
}

int luaopen_mj_hotkey_internal(lua_State* L) {
    handlers = [[NSMutableIndexSet indexSet] retain];
    
    luaL_newlib(L, hotkeylib);
    
    // watch for hotkey events
    EventTypeSpec hotKeyPressedSpec[] = {{kEventClassKeyboard, kEventHotKeyPressed}, {kEventClassKeyboard, kEventHotKeyReleased}};
    InstallEventHandler(GetEventDispatcherTarget(), hotkey_callback, sizeof(hotKeyPressedSpec) / sizeof(EventTypeSpec), hotKeyPressedSpec, L, NULL);
    
    // put hotkey in registry; necessary for luaL_checkudata()
    lua_pushvalue(L, -1);
    lua_setfield(L, LUA_REGISTRYINDEX, "mj.hotkey");
    
    // hotkey.__index = hotkey
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    
    return 1;
}
