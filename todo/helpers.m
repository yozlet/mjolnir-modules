#import "helpers.h"

void hydra_push_luavalue_for_nsobject(lua_State* L, id obj) {
    if (obj == nil || [obj isEqual: [NSNull null]]) {
        lua_pushnil(L);
    }
    else if ([obj isKindOfClass: [NSDictionary class]]) {
        lua_newtable(L);
        NSDictionary* dict = obj;

        for (id key in dict) {
            hydra_push_luavalue_for_nsobject(L, key);
            hydra_push_luavalue_for_nsobject(L, [dict objectForKey:key]);
            lua_settable(L, -3);
        }
    }
    else if ([obj isKindOfClass: [NSNumber class]]) {
        if (obj == (id)kCFBooleanTrue)
            lua_pushboolean(L, YES);
        else if (obj == (id)kCFBooleanFalse)
            lua_pushboolean(L, NO);
        else
            lua_pushnumber(L, [(NSNumber*)obj doubleValue]);
    }
    else if ([obj isKindOfClass: [NSString class]]) {
        NSString* string = obj;
        lua_pushstring(L, [string UTF8String]);
    }
    else if ([obj isKindOfClass: [NSDate class]]) {
        // not used for json, only in applistener; this should probably be moved to helpers
        NSDate* string = obj;
        lua_pushstring(L, [[string description] UTF8String]);
    }
    else if ([obj isKindOfClass: [NSArray class]]) {
        lua_newtable(L);

        int i = 0;
        NSArray* list = obj;

        for (id item in list) {
            hydra_push_luavalue_for_nsobject(L, item);
            lua_rawseti(L, -2, ++i);
        }
    }
}



static BOOL is_sequential_table(lua_State* L, int idx) {
    NSMutableIndexSet* iset = [NSMutableIndexSet indexSet];

    lua_pushnil(L);
    while (lua_next(L, idx) != 0) {
        if (lua_isnumber(L, -2)) {
            double i = lua_tonumber(L, -2);
            if (i >= 1 && i <= NSNotFound - 1)
                [iset addIndex:i];
        }
        lua_pop(L, 1);
    }

    return [iset containsIndexesInRange:NSMakeRange([iset firstIndex], [iset lastIndex] - [iset firstIndex] + 1)];
}

id hydra_nsobject_for_luavalue(lua_State* L, int idx) {
    idx = lua_absindex(L,idx);

    switch (lua_type(L, idx)) {
        case LUA_TNIL: return [NSNull null];
        case LUA_TNUMBER: return @(lua_tonumber(L, idx));
        case LUA_TBOOLEAN: return lua_toboolean(L, idx) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
        case LUA_TSTRING: return [NSString stringWithUTF8String: lua_tostring(L, idx)];
        case LUA_TTABLE: {
            if (is_sequential_table(L, idx)) {
                NSMutableArray* array = [NSMutableArray array];

                for (int i = 0; i < lua_rawlen(L, idx); i++) {
                    lua_rawgeti(L, idx, i+1);
                    id item = hydra_nsobject_for_luavalue(L, -1);
                    lua_pop(L, 1);

                    [array addObject:item];
                }
                return array;
            }
            else {
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                lua_pushnil(L);
                while (lua_next(L, idx) != 0) {
                    if (!lua_isstring(L, -2)) {
                        lua_pushliteral(L, "json map key must be a string");
                        lua_error(L);
                    }

                    id key = hydra_nsobject_for_luavalue(L, -2);
                    id val = hydra_nsobject_for_luavalue(L, -1);
                    [dict setObject:val forKey:key];
                    lua_pop(L, 1);
                }
                return dict;
            }
        }
        default: {
            lua_pushliteral(L, "non-serializable object given to json");
            lua_error(L);
        }
    }
    // unreachable
    return nil;
}
