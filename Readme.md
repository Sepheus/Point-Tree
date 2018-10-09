### Purpose
	Find the most isolated point in within an arbitrary set of points within a reasonable time-frame.

### Build instructions:
	Install the D language for your platform from https://dlang.org/
	Install the DUB package manager for your platform from https://code.dlang.org/download
	Run build.bat or input "dub build --build=release" at the command line.

### Run instructions:
	Simply input most_isolated < problem at the command line.  E.g ./most_isolated < problem_big.txt
	run.bat will run the two default problem sets.

### Example output for an invocation:
	Parsing time: 223ms
	Algorithm time: 15ms
	place55163


### Thoughts:
	The algorithmic part runs just fine.  O(n log n) to find the solution to the problem.
	Parsing on the other hand is extremely slow but this could be down to STDIN.
	Unfortuantely the D documentation doesn't really give you a lot of information about handling STDIN.
	The time could perhaps be improved by reading every line into memory and performing a compiled regex across that.