import std.algorithm.iteration;
import std.algorithm.searching;
import std.array;
import std.file;
import std.parallelism;
import std.path;
import std.process;
import std.range;
import std.stdio;

import ae.sys.file;
import ae.utils.graphics.color;
import ae.utils.graphics.image;
import ae.utils.graphics.im_convert;
import ae.utils.xmllite;

enum potrace = `C:\Soft\potrace\potrace.exe`;
enum frameCount = 120;
enum tmpDir = `A:\tmp\2015-03-28`;

void main()
{
	XmlNode[] svgFrames;
	foreach (frame; frameCount.iota.parallel)
	{
		auto frameFn = "../a%03d.png".format(frame);
		if (!frameFn.exists) continue;
		writeln(frameFn);
		const bg = BGR(255, 255, 255);

		auto img = parseViaIMConvert!BGR(frameFn.read());
		BGR[] colors;
		foreach (p; img.pixels)
			if (!colors.canFind(p))
				colors ~= p;

		XmlDocument[] svgs;

		foreach (color; colors)
			if (color != bg)
			{
				auto colorStr = color.toHex;
				writeln(colorStr);
				auto fn = "layer-%03d-%s.bmp".format(frame, colorStr);
				fn = buildPath(tmpDir, fn);

				auto layer = img.copy();
				foreach (ref p; layer.pixels)
					p = p == color ? BGR.init : BGR(255, 255, 255);
				layer.toBMP.toFile(fn);
				scope(exit) fn.remove();

				spawnProcess([
					potrace,
					fn,
					"--svg",
					"--alphamax", "0",
					"--opttolerance", "0.2",
					"--color", "#" ~ colorStr,
				]).wait();

				auto svgFn = fn.setExtension(".svg");
				svgs ~= svgFn.readText().xmlParse();
				//svgFn.remove();
			}

		auto svgFrame = new XmlNode(XmlNodeType.Node, "g");
		svgFrame.children = svgs.map!(svg => svg["svg"]["g"]).array();

		auto animate = new XmlNode(XmlNodeType.Node, "animate");
		animate.attributes["attributeName"] = "display";
		animate.attributes["values"] = frameCount.iota.map!(n => n==frame ? "inline" : "none").join(";");
		animate.attributes["begin"] = "0s";
		animate.attributes["repeatCount"] = "indefinite";
		animate.attributes["dur"] = "2s";
		svgFrame.children ~= animate;

		synchronized
			svgFrames ~= svgFrame;
	}

	auto svg = xmlParse(q"EOF
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="4096" height="4096">
</svg>
EOF");

	svg["svg"].children = svgFrames;
	svg.toString().toFile("a.svg");
}
