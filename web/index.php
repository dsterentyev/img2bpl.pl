<?php
$error = false;
if(isset($_REQUEST['cmd']) && $_REQUEST['cmd'] == 'post')
{
//	print_r($_FILES);
	if(isset($_FILES['img']) && $_FILES['img']['error'] === 0)
	{
		$filename = iconv("UTF-8", "ISO-8859-1//TRANSLIT", preg_replace('/\.(jpg|jpeg|png)/i', '', $_FILES['img']['name']));
		$filename = preg_replace('/\W/', '_', $filename);
		$realname = $_FILES['img']['tmp_name'];
		$vshift = isset($_REQUEST['vshift']) ? 1 : 0;
		$bblock = isset($_REQUEST['bblock']) ? 1 : 0;
		$fontsize = (isset($_REQUEST['fs']) && round($_REQUEST['fs'] * 5) >= 1 && round($_REQUEST['fs'] <= 20)) ? round($_REQUEST['fs'] * 20) / 20.0 : 9;
		$tc = (isset($_REQUEST['tc']) && in_array($_REQUEST['tc'], array('1', '2', '3', '4'))) ? $_REQUEST['tc'] : 1;
		if(! isset($_REQUEST['alt']))
		{
			$res0 = exec("./img2bpl.pl '$realname' '$filename' $vshift $bblock $fontsize $tc > '$realname.blueprint'", $out, $res);
		}
		else
		{
			$res0 = exec("./img2bpl_alt.pl '$realname' '$filename' > '$realname.blueprint'", $out, $res);
		}
		if($res0 !== false && $res == 0)
		{
			if(! isset($_REQUEST['alt']))
			{
				header('Content-type: application/octet-stream');
				header("Content-Disposition: attachment; filename=\"$filename.blueprint\"");
				readfile("$realname.blueprint");
				unlink("$realname.blueprint");
				exit;
			}
			else
			{
				header('Content-type: text/plain');
				readfile("$realname.blueprint");
				unlink("$realname.blueprint");
				exit;
			}
		}
		else
		{
			if(is_array($out))
			{
				$out = implode(', ', $out);
			}
			$error = "image process error ($out)!";
		}
	}
	else
	{
		$error = "file upload error!";
	}
}
?>
<html><head><title>Valheim image to blueprint converter</title></head>
<body>
<h2>Valheim image to blueprint converter</h2>
(based on <a href="https://github.com/dsterentyev/img2bpl.pl">https://github.com/dsterentyev/img2bpl.pl</a>)</p>
<?php
if($error !== false)
{
	echo ('<div style="border: 1px solid red; padding: 4px; background-color: #CCCCCC;">');
	echo (htmlspecialchars($error));
	echo ('</div>');
}
?>
<hr size="1">
<form action="index.php" method="post" enctype="multipart/form-data">
<p>Upload your image (png or jpg, maximum size 480x480 pixels, png with transparency supported):&nbsp;</p>
<input type="hidden" name="MAX_FILE_SIZE" value="500000" />
<input type="file" name="img" accept="image/png, image/jpeg">
<p>Do not shift vertically: <input type="checkbox" name="vshift" /></p>
<p>Do not include support block: <input type="checkbox" name="bblock" /></p>
<p>Pixel size:
<select name="fs">
<option value="0.2">0.2</option>
<option value="0.25">0.25</option>
<option value="0.3">0.3</option>
<option value="0.35">0.35</option>
<option value="0.4">0.4</option>
<option value="0.45">0.45</option>
<option value="0.5">0.5</option>
<option value="0.75">0.75</option>
<option value="1">1</option>
<option value="1.5">1.5</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9" selected>9</option>
<option value="10">10</option>
<option value="11">11</option>
<option value="12">12</option>
<option value="13">13</option>
<option value="14">14</option>
<option value="15">15</option>
<option value="16">16</option>
<option value="17">17</option>
<option value="18">18</option>
<option value="19">19</option>
<option value="20">20</option>
</select></p>
<p>Transparent color:
<select name="tc">
<option value="1" selected>None</option>
<option value="2">White</option>
<option value="3">Black</option>
<option value="4">Green</option>
</select></p>
<p>Simple no blueprint version suitable for small resolution: <input type="checkbox" name="alt" /><br>
(Resolution more than approx 120px width may crash the game. Use text output as a text for a single sign) </p>
<input type="hidden" name="cmd" value="post">
<input type="submit" value="Conform upload">
<hr size="1">
</form>
</body>
</html>
