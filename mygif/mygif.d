import std.algorithm.iteration;
import std.algorithm.searching;
import std.array;
import std.file;
import std.math;
import std.parallelism;
import std.path;
import std.process;
import std.random;
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

		void shiftRow(int y, int s)
		{
			s = img.w - s;
			if (s && s != img.w)
				img.scanline(y)[] = img.scanline(y)[s..$] ~ img.scanline(y)[0..s];
		}

		void shiftBand(int shiftHeight, int shiftOffset)
		{
			foreach (int n; 0..shiftHeight)
			{
				auto y = (n + frame + shiftOffset) % img.h;
				auto s = (shiftHeight/2) - abs(n - (shiftHeight / 2));
				if (s)
					s = uniform(0, s);
				shiftRow(y, s);
			}
		}
		shiftBand(20, 70);
		shiftBand(15, 50);

		foreach (y; 0..img.h)
			shiftRow(y, uniform(0, 2));

		foreach (y; 0..img.h)
			foreach (ref p; img.scanline(y))
				if ((y+frame) % 3)
					p.g /= 4;
				else
					p.g = cast(ubyte)(p.g * 7 / 8 + 256 / 8);

		img.colorMap!(c => RGB(c.r,c.g,c.b)).toPNG.toFile("a%03d.png".format(frame));
	}
}
