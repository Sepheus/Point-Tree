/* Leverages the D language and KD Tree to quickly determine the most isolated point in a problem set.
 * Expects input in the form of label point point separated by newlines.
 * This program reads from STDIN.
 * Example usage: most_isolated < problem_small.txt
 * Expected output
 * place6
 * Parsing time: 0ms
 * Algorithm time: 0ms
 */

import std.stdio : writeln, writefln, readln, stdin;  //Only import the symbols we need to keep binary size down.
import std.datetime : Clock, Duration;
import std.conv : to;
import std.regex : matchFirst, ctRegex;
import std.parallelism;
import wrld.kdtree;

void main() {
	auto clockStart = Clock.currTime();
	KdNode!2[] nodes;
	try {
		getInput(nodes);
	}
	catch(Exception e) {
		writeln("Input was erroneous."); //Generic catch all.
	}
	auto clockEnd = Clock.currTime();
	auto parseDur = clockEnd - clockStart;
	
	auto root = makeTree(nodes);
	clockStart = Clock.currTime();
	string mostDistant = findMostDistant(nodes, root);
	clockEnd = Clock.currTime();
	auto algoDur = clockEnd - clockStart;
	
	writefln("Parsing time: %sms", parseDur.total!"msecs");
	writefln("Algorithm time: %sms", algoDur.total!"msecs");
	writeln(mostDistant);
}

///Acquire input from STDIN and populate nodes.
void getInput(ref KdNode!2[] nodes) {
	auto ctr = ctRegex!(`(?P<label>\w+) (?P<x>\d+) (?P<y>\d+)`);
	foreach(line; stdin.byLine) {
		KdNode!2 node;
		auto point = line.matchFirst(ctr);
		node.x = [point["x"].to!double, point["y"].to!double];
		node.label = point["label"].to!string;
		nodes ~= node;
	}
}

///Traverse the KD Tree to find the label of the most distant node.
string findMostDistant(ref KdNode!2[] nodes, ref KdNode!2 *root) {
	string mostDistant;
	double maxDist = 0;
	foreach(point; nodes.parallel) {
		const(KdNode!2)* found;
		double bestDist = 0;
		size_t nVisited;
		root.nearest(point, 0, found, bestDist, nVisited);
		if(maxDist < bestDist) {
			mostDistant = point.label;
			maxDist = bestDist;
		}
	}
	return mostDistant;
}