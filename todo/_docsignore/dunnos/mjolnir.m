#import "helpers.h"

/// hydra.focushydra()
/// Makes Hydra the currently focused app; useful in combination with textgrids.
static int hydra_focushydra(lua_State* L) {
    [NSApp activateIgnoringOtherApps:YES];
    return 0;
}
