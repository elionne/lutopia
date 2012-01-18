#include <stdio.h>
#include <stdlib.h>

#include <lua.h>
#include <lauxlib.h>

#define LIGHT "light"

void dbg_lua(lua_State *L, int err, const char *msg)
{
    if( err ){
        printf("%s: Error while executing file\n", msg);
        switch( err ){
            case LUA_ERRFILE:
                printf("couldn't open the given file\n");
                exit(-1);
            case LUA_ERRSYNTAX:
                printf("syntax error during pre-compilation\n");
                exit(-1);
            case LUA_ERRMEM:
                printf("memory allocation error\n");
                exit(-1);
            case LUA_ERRRUN:
                printf("%s\n", lua_tostring(L, -1));
                exit(-1);
            case LUA_ERRERR:
                printf("error while running the error handler function\n");
                exit(-1);
            default:
                printf("unknown error %i\n", err);
                exit(-1);
        }
    }
}

void new_light(lua_State *L, unsigned int addr, const char *universe,
                                                const char *type,
                                                const char *name)
{
    int err;

    lua_getglobal(L, LIGHT);
    if( !lua_istable(L, -1) ){
        printf("Internal error: global \"%s\"table is not defined\n", LIGHT);
        lua_pop(L, 1);
        goto error;
    }

    lua_getfield(L, -1, type);
    if( !lua_istable(L, -1) ){
        printf("\"%s\" type, is not defined\n", type);
        lua_pop(L, 2);
        goto error;
    }

    lua_getglobal(L, universe);
    if( !lua_istable(L, -1) ){
        printf("Internal error: global \"%s\"table is not defined\n", universe);
        lua_pop(L, 3);
        goto error;
    }

    lua_getfield(L, -2, "new");
    if( !lua_isfunction(L, -1) ){
        printf("\"%s.new()\" function, is not defined\n", type);
        lua_pop(L, 4);
        goto error;
    }

    lua_pushinteger(L, addr);
    err = lua_pcall(L, 1, 1, 0);
    dbg_lua(L, err, "light.type.new");
    if( !lua_istable(L, -1) ){
        printf("\"%s\" not created!\n", type);
        goto error;
    }

    lua_setfield(L, -2, name);

    /* pops 'type', 'light' and 'universe' from stack */
    lua_pop(L, 3);

error:
    return;
}

void new_group(lua_State *L, const char *universe, const char *name)
{
    lua_getglobal(L, universe);
    if( !lua_istable(L, -1) ){
        printf("Internal error: global \"%s\"table is not defined\n", universe);
        lua_pop(L, 1);
        goto error;
    }

    lua_newtable(L);
    lua_setfield(L, -2, name);

    /* pops 'universe' from the stack */
    lua_pop(L, 1);

error:
    return;
}

void link_into_group(lua_State *L, const char *universe, const char *group,
                                                         const char *var)
{
    lua_getglobal(L, universe);
    if( !lua_istable(L, -1) ){
        printf("Internal error: global \"%s\" table is not defined\n", universe);
        lua_pop(L, 1);
        goto error;
    }

    lua_getfield(L, -1, group);
    if( !lua_istable(L, -1) ){
        printf("'%s' group is not defined in universe '%s'\n", group, universe);
        lua_pop(L, 2);
        goto error;
    }

    lua_getfield(L, -2, var);
    if( !lua_istable(L, -1) ){
        printf("'%s' light is not define in universe '%s'\n", var, universe);
        lua_pop(L, 2);
        goto error;
    }

    lua_setfield(L, -2, var);

    /* pops 'universe' and 'group' from the stack */
    lua_pop(L, 2);

error:
    return;
}

void new_global_light(lua_State *L)
{
    lua_newtable(L);
    lua_setglobal(L, LIGHT);
}

void new_universe(lua_State *L, const char *universe)
{
    lua_newtable(L);
    lua_setglobal(L, universe);
}

int main()
{
    lua_State *L = luaL_newstate();

    int err;

    luaL_openlibs(L);

    new_global_light(L);
    new_universe(L, "u");
    new_group(L, "u", "group1");


    err = luaL_loadfile(L, "api.lua");
    dbg_lua(L, err, "api.lua");
    err = lua_pcall(L, 0, LUA_MULTRET, 0);
    dbg_lua(L, err, "api.lua");

    new_light(L, 235, "u", "parled", "test1");
    link_into_group(L, "u", "group1", "test1");

    err = luaL_loadfile(L, "test.lua");
    dbg_lua(L, err, "test.lua");
    err = lua_pcall(L, 0, LUA_MULTRET, 0);
    dbg_lua(L, err, "test.lua");

    lua_close(L);
    return 0;
}