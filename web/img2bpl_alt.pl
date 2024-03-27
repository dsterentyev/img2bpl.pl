#!/usr/bin/perl

use Image::Magick;
use Data::Dump qw/dump/;

$imgfile = shift @ARGV;
$bplname = shift @ARGV;
$vshift = 0;
$bblock = 1;

#`echo "$imgfile $bplname $vshift $bblock $fontsize $tc" > lastrun.dat`;

if (! $imgfile || ! $bplname)
{
	print "Script for converting image file to valheim blueprint (for PlanBuild mod)\n";
	print "usage: img2bpl.pl image_file blueprint_name > blueprint_name.blueprint\n"; 
	exit;
}

$image = new Image::Magick;
$image->Read($imgfile);
die("Error: can not read image from file!") if ! $image->[0];

$w = $image->[0]->Get('columns');
$h = $image->[0]->Get('rows');

$fontsize = 0.19 * (90 / $w);

die("Image size too big\n") if $w > 480 || $h > 480;
die("Image size too small\n") if $w == 0 || $h == 0;

$pixsz = 0.3 * ($fontsize / 9.0);

$colt = '<cspace=-0.2em><line-height=85%><nobr>';

$st1 = "";

$pixdef = '<color=#~rgb~>█';
$pixdefa = '█';

$lrgb = '';
for($y = 0; $y < $h; $y ++)
{
	$l1_1 = '';
	for($x = 0; $x < $w; $x++)
	{
		$col = $colt;
		$pix1_1 = $pixdef;
		$rgb1_1 = get_pixel_rgb($image, $x, $y);
		$pix1_1 =~ s/~rgb~/$rgb1_1/;
		$l1_1 .= $lrgb ne $pix1_1 ? $pix1_1 : $pixdefa;
		$lrgb = $pix1_1;
	}
	$st1 .= "$l1_1\n" ;
}
$colt = "<size=$fontsize>$colt";
$colt .= $st1;
print($colt);

sub get_pixel_rgb
{
	$timg = $_[0];
	$xx = $_[1];
	$yy = $_[2];
	@p = $timg->GetPixels(
		'width'   => 1,
		'height'  => 1,
		'x'       => $xx,
		'y'       => $yy,
		map       => 'RGBA',
		normalize => 'True',
	);
#	print STDERR dump(@p);
	return($p[3] == 1 ? sprintf("%02x%02x%02x", int($p[0] * 255), int($p[1] * 255), int($p[2] * 255)) : sprintf("%02x%02x%02x%02x", int($p[0] * 255), int($p[1] * 255), int($p[2] * 255), int($p[3] * 255)));
}
