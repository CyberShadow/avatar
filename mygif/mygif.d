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
import ae.utils.graphics.gamma;
import ae.utils.graphics.image;
import ae.utils.graphics.im_convert;
import ae.utils.xmllite;

enum frameCount = 100;
enum tmpDir = `A:\tmp\avatar`;

void main()
{
	auto gamma = GammaRamp!(ushort, ubyte)(ColorSpace.sRGB);

	foreach (frame; frameCount.iota.parallel)
	{
		auto frameFn = "../a%03d.png".format(frame);
		if (!frameFn.exists) continue;
		writeln(frameFn);

		auto img = parseViaIMConvert!BGR(frameFn.read());

		img = img
			.pix2lum(gamma)
			.copy()
			.downscale!8()
			.lum2pix(gamma)
			.copy();

		foreach (ref p; img.pixels)
		{
			p.g = 255 - p.g;
			p.r = p.b = 0;
		}

		foreach (y; 0..img.h)
			foreach (ref p; img.scanline(y))
				if ((y+frame) % 3)
					p.g /= 4;
				else
					p.g = cast(ubyte)(p.g * 7 / 8 + 256 / 8);

		img.colorMap!(c => RGB(c.r,c.g,c.b)).toPNG.toFile("a%03d.png".format(frame));
	}
}
