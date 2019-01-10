import std.stdio;

import game.menu;

void main(string[] args) {
	try {
		setupApplication(args);
	}
	catch(Exception e) {
		writeln(e.msg);
	}
}
