all: vt_lua 

vt_lua: vt_lua.o cuecable.o
	gcc -o vt_lua vt_lua.o cuecable.o -llua -lusb-1.0

vt_lua.o: vt_lua.c
	gcc -g -Wall -c -o vt_lua.o vt_lua.c
cuecable.o: cuecable.c cuecable.h
	gcc -g -Wall -c -o cuecable.o cuecable.c
