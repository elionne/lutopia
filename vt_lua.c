#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

/* lua includes */
#include <lua.h>
#include <lauxlib.h>

#include "cuecable.h"

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

    lua_getglobal(L, type);
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

    /* pops 'light' and 'universe' from stack */
    lua_pop(L, 2);

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

void new_global_table(lua_State *L, const char *table)
{
    lua_newtable(L);
    lua_setglobal(L, table);
}

void new_universe(lua_State *L, const char *universe)
{
    lua_newtable(L);
    lua_setglobal(L, universe);
}


/* Light in use must be on the top of stack. when this function returns, current
 * light still on stack.
 */
int send_dmx(lua_State *L, libusb_device_handle* cue)
{
    int err;
    short start_addr;

    lua_getfield(L, -1, "dmx");
    if( !lua_isfunction(L, -1) ){
        printf("no dmx function found\n");
        return 0;
    }

    /* push self (light) parameter */
    lua_pushvalue(L, -2);
    err = lua_pcall(L, 1, 1, 0);
    dbg_lua(L, err, "dmx");

    if( !lua_istable(L, -1) ){
        printf("error occurs when excuting dmx function\n");
        return 0;
    }

    lua_getfield(L, -1, "addr");
    if( !lua_isnumber(L, -1) ){
        printf("no 'addr' field found, couldn't send dmx data.\n");
        return 0;
    }

    start_addr = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_pushnil(L);
    while( lua_next(L, -2) ){
        if( lua_isnumber(L, -2) ){
            short index = lua_tointeger(L, -2);
            char  value = (char)(lua_tonumber(L, -1) * 255);

            //printf("addr %i, key : %i, value : %hhu\n", start_addr, index, value);

            cue_dmx(cue, start_addr + index, value);
            cue_sync(cue);
        }
        lua_pop(L, 1);
    }

    lua_pop(L, 1);

    return 1;
}

/* This function
 * TODO comment it!
 */
int update_lights(lua_State *L, const char *universe, libusb_device_handle* cue)
{
    int err;

    lua_getglobal(L, universe);
    if( !lua_istable(L, -1) ){
        printf("%s not found\n", universe);
        return 0;
    }

    lua_pushnil(L);
    while( lua_next(L, -2) ){
        if( lua_istable(L, -1) ){

            lua_getfield(L, -1, "is_changed");
            if( lua_isnil(L, -1) ){
                lua_pop(L, 2);
                continue;
            }

            /* push self first argument */
            lua_pushvalue(L, -2);

            err = lua_pcall(L, 1, 1, 0);
            dbg_lua(L, err, "is_changed");

            /*
            printf("light : %s, changed %i\n", lua_tostring(L, 2),
                                               lua_tointeger(L, -1));
            */
            if( lua_toboolean(L, -1) ){
                /* pops the result of 'is_changed' */
                lua_pop(L, 1);

                /* send dmx data */
                send_dmx(L, cue);

                /* pops light */
                lua_pop(L, 1);
            }else
                lua_pop(L, 2);

        }
    }
    lua_pop(L, 1);

    return 0;
}

int lt_sleep(lua_State *L)
{
    struct timespec how_long;

    float u_sec = lua_tonumber(L, -1);
    lua_pop(L, 1);

    if( u_sec > 1e6 ){
        how_long.tv_sec = (time_t)(u_sec / 1e6);
        how_long.tv_nsec = (long)(u_sec * 1e3 - how_long.tv_sec * 1e9);
    }else{
        how_long.tv_sec = 0;
        how_long.tv_nsec = u_sec * 1e3;
    }

    nanosleep(&how_long, 0);
    return 0;
}

void register_lt_functions(lua_State *L)
{
    lua_register(L, "usleep", lt_sleep);
}

int main()
{
    libusb_device_handle* cue = cue_open();
    lua_State *L = luaL_newstate();

    int err;

    luaL_openlibs(L);

    new_global_table(L, LIGHT);

    register_lt_functions(L);

    new_universe(L, "u");
    new_group(L, "u", "group1");

    err = luaL_loadfile(L, "api.lua");
    dbg_lua(L, err, "api.lua");
    err = lua_pcall(L, 0, LUA_MULTRET, 0);
    dbg_lua(L, err, "api.lua");

    new_light(L, 1, "u", "parled", "test1");
    link_into_group(L, "u", "group1", "test1");

    err = luaL_loadfile(L, "test.lua");
    dbg_lua(L, err, "test.lua");
    err = lua_pcall(L, 0, LUA_MULTRET, 0);
    dbg_lua(L, err, "test.lua");

    double p = 0;

    for(p = 0; p <= 1 ; p += 0.002 ){
        int err;

        lua_getglobal(L, "main");
        if( !lua_isfunction(L, -1) ){
            printf("\"main\" function, is not defined\n");
            break;
        }
        lua_pushnumber(L, p);
        err = lua_pcall(L, 1, 0, 0);
        dbg_lua(L, err, "main");

        update_lights(L, "u", cue);

        //printf("%g\r", p);
        //fflush(stdout);
        usleep(25000);
    }

    lua_close(L);
    cue_close(cue);
    return 0;
}
