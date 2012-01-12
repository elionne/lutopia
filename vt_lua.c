/* gcc -ansi vt_lua.c -o vt_lua -llua */

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

void new_light(lua_State *L, unsigned int addr, char *type, char *name)
{
	int err;

	lua_getglobal(L, LIGHT);
	if( !lua_istable(L, -1) ){
		printf("Internal error: global \"%s\"table is not defined\n", LIGHT);
		goto error;
	}

	lua_getfield(L, -1, type);
	if( !lua_istable(L, -1) ){
		printf("\"%s\" type, is not defined\n", type);
		goto error;
	}

	lua_getfield(L, -1, "new");
	if( !lua_isfunction(L, -1) ){
		printf("\"%s.new()\" function, is not defined\n", type);
		goto error;
	}

	lua_pushnil(L); /* self */
	lua_pushnumber(L, addr);
	err = lua_pcall(L, 2, 1, 0);
	dbg_lua(L, err, "light.type.new");
	if( !lua_istable(L, -1) ){
		printf("\"%s\" not created\n", type);
		goto error;
	}

	lua_setglobal(L, name);

	lua_pop(L, 2);

error:
	return;
}

new_global_light(lua_State *L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, LIGHT);
}

int main()
{
	lua_State *L = luaL_newstate();

	int err;

	luaL_openlibs(L);
	new_global_light(L);
	
	err = luaL_loadfile(L, "api.lua");
	dbg_lua(L, err, "api.lua");
	err = lua_pcall(L, 0, LUA_MULTRET, 0);
	dbg_lua(L, err, "api.lua");

	new_light(L, 235, "parled", "test1");
	
	err = luaL_loadfile(L, "test.lua");
	dbg_lua(L, err, "test.lua");
	err = lua_pcall(L, 0, LUA_MULTRET, 0);
	dbg_lua(L, err, "test.lua");

error:
	lua_close(L);
	return -1;

}