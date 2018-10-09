/* Code from https://rosettacode.org/wiki/K-d_tree#Faster_Alternative_Version
 * Modified slightly for points to ignore themselves as neighbours.
 * Labels also attached to KdNodes.
*/

module wrld.kdtree;

import std.algorithm : swap;

struct KdNode(size_t dim) {
	string label;
    double[dim] x;
    KdNode* left, right;
}

// See QuickSelect method (query visits fewer nodes).
KdNode!dim* findMedian(size_t idx, size_t dim)(KdNode!dim[] nodes) pure nothrow @nogc {
    auto start = nodes.ptr;
    auto end = &nodes[$ - 1] + 1;

    if (end <= start)
        return null;
    if (end == start + 1)
        return start;

    auto md = start + (end - start) / 2;

    while (true) {
        immutable double pivot = md.x[idx];

        swap(md.x, (end - 1).x); // Swaps the whole arrays x.
		swap(md.label, (end - 1).label);
        auto store = start;
        foreach (p; start .. end) {
            if (p.x[idx] < pivot) {
                if (p != store) {
                    swap(p.x, store.x);
					swap(p.label, store.label);
				}
                store++;
            }
        }
        swap(store.x, (end - 1).x);
		swap(store.label, (end - 1).label);

        // Median has duplicate values.
        if (store.x[idx] == md.x[idx])
            return md;

        if (store > md)
            end = store;
        else
            start = store;
    }
}

KdNode!dim* makeTree(size_t dim, size_t i = 0)(KdNode!dim[] nodes)
pure nothrow @nogc {
    if (!nodes.length)
        return null;

    auto n = nodes.findMedian!i;
    if (n != null) {
        enum i2 = (i + 1) % dim;
        immutable size_t nPos = n - nodes.ptr;
        n.left = makeTree!(dim, i2)(nodes[0 .. nPos]);
        n.right = makeTree!(dim, i2)(nodes[nPos + 1 .. $]);
    }

    return n;
}

void nearest(size_t dim)(in KdNode!dim* root, in ref KdNode!dim nd, in size_t i, ref const(KdNode!dim)* best, ref double bestDist, ref size_t nVisited) pure nothrow @safe @nogc {
	static double dist(in ref KdNode!dim a, in ref KdNode!dim b)
		pure nothrow @nogc {
			double result = 0;
			static foreach (i; 0 .. dim)
				result += (a.x[i] - b.x[i]) ^^ 2;
			return result;
		}

	if (root == null)
		return;

	immutable double d = dist(*root, nd);
	immutable double dx = root.x[i] - nd.x[i];
	immutable double dx2 = dx ^^ 2;
	nVisited++;

	if (!best || d < bestDist && d > 0) {
		bestDist = d;
		best = root;
	}

	// If chance of exact match is high.
	if (!bestDist)
		return;

	immutable i2 = (i + 1 >= dim) ? 0 : i + 1;

	nearest!dim(dx > 0 ? root.left : root.right,
				nd, i2, best, bestDist, nVisited);
	if (dx2 >= bestDist)
		return;
	nearest!dim(dx > 0 ? root.right : root.left,
				nd, i2, best, bestDist, nVisited);
}