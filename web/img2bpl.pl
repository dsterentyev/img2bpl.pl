#!/usr/bin/perl

use Image::Magick;
use Data::Dump qw/dump/;

$imgfile = shift @ARGV;
$bplname = shift @ARGV;
$vshift = shift @ARGV;
$bblock = shift @ARGV;
$fontsize = shift @ARGV;
@tccols = ('', '-', 'ffffff', '000000', '00ff00');
$tc = shift(@ARGV);

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

die("Image size too big\n") if $w > 480 || $h > 480;
die("Image size too small\n") if $w == 0 || $h == 0;

$header = '#Name:~name~
#Creator:img2bpl.pl
#Description:""
#Category:img2bpl
#Pieces
' . ( $bblock != 1 ? 'wood_pole;Building;0;0;0;0;1;0;0;"";1;1;1
' : '');

$header =~ s/~name~/$bplname/;
print $header;

$pixsz = 0.3 * ($fontsize / 9.0);				# 0.3017578 - 0.1018066;
$xstart = - $w * $pixsz / 2;
#$z1 = $h * $pixsz / 2;
$z1 = $pixsz;
$z2 = $z1 + $pixsz * 1.1;

$pixelt = '<color=#~rgb~>■\n';

$colt = 'sign;Furniture;~x~;~z1~;0;1;0;0;0;"<size=' . $fontsize . '>~pix1~";1;1;1
sign;Furniture;~x~;~z2~;0;1;0;0;0;"<size=' . $fontsize . '>~pix2~";1;1;1
';

for($x = 0; $x < $w; $x++)
{
	$col = $colt;
	if(! $vshift)
	{
		$pix1 = '\n' x int($h / 1.45);
		$pix2 = '\n' x int($h / 1.45);
	}
	else 
	{
		$pix1 = '';
		$pix2 = '';
	}
	for($y = 0; $y < int($h / 2); $y ++)
	{
		$rgb1 = get_pixel_rgb($image, $x, $h - $y * 2 + 1);
		$rgb2 = get_pixel_rgb($image, $x, $h - $y * 2 + 0);

		$rgb1 = $rgb1 eq $tccols[$tc] ? '00000000' : $rgb1;
		$rgb2 = $rgb2 eq $tccols[$tc] ? '00000000' : $rgb2;

		$pix1t = $pixelt;
		$pix2t = $pixelt;

		$pix1t =~ s/~rgb~/$rgb1/;
		$pix2t =~ s/~rgb~/$rgb2/;
		$pix1 .= $pix1t;
		$pix2 .= $pix2t;
	}
	$col =~ s/~pix1~/$pix1/;
	$col =~ s/~pix2~/$pix2/;
	$col =~ s/~z1~/$z1/;
	$col =~ s/~z2~/$z2/;
	$col =~ s/~x~/$xstart/g;
	print $col;
	$xstart += $pixsz * 1.1;
}

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
	if($p[4] == 1)
	{
		return(sprintf("%02x%02x%02x", int($p[0] * 255), int($p[1] * 255), int($p[2] * 255)));
	}
	else
	{
		return(sprintf("%02x%02x%02x%02x", int($p[0] * 255), int($p[1] * 255), int($p[2] * 255), int($p[3] * 255)));
	}
}
