all: vt_lua cuecable

vt_lua: vt_lua.c
	gcc -g -o vt_lua vt_lua.c -llua
cuecable: cuecable.c
	gcc -g -o cuecable cuecable.c -lusb-1.0
