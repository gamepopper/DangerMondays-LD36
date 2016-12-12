package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import nape.phys.BodyType;

import flixel.util.FlxTimer;

class MenuState extends FlxState
{
	var timer:FlxTimer;
	
	override public function create():Void
	{
		super.create();
		FlxNapeSpace.init();
		FlxNapeSpace.createWalls(0, 0, 640, FlxG.height + 30);
		
		var background = new FlxSprite(0, 0, "assets/images/background.png");
		var title = new FlxSprite(-48, 0, "assets/images/title.png");
		
		var loo = new FlxSprite();
		loo.loadGraphic("assets/images/portaloo.png");
		loo.x = 160 + 80 - 16;
		loo.y = 96 - 32;
		
		var text = new FlxText(0, FlxG.height - 25, 320, 
			"Developed by Gamepopper for Ludum Dare 36\nWARNING: Contains stuff found in toilets", 8);
		text.alignment = FlxTextAlign.CENTER;
		
		add(background);
		add(title);
		add(loo);
		
		var pole = new FlxNapeSprite();
		pole.loadGraphic("assets/images/pole.png");
		pole.createRectangularBody();
		pole.body.position.x = 160 + 80 + 56 + 4;
		pole.body.position.y = 184 - 56 + 4;
		pole.body.rotation = 90 / 180 * 3.14;
		add(pole);
		
		pole = new FlxNapeSprite();
		pole.loadGraphic("assets/images/pole.png");
		pole.createRectangularBody(0, 0, BodyType.KINEMATIC);
		pole.body.position.x = 160 + 80;
		pole.body.position.y = 184;
		add(pole);
		
		pole = new FlxNapeSprite();
		pole.loadGraphic("assets/images/pole.png");
		pole.createRectangularBody();
		pole.body.position.x = 160 + 80 - 56 - 2;
		pole.body.position.y = 184 - 56 + 4;
		pole.body.rotation = 90 / 180 * 3.14;
		add(pole);
		
		pole = new FlxNapeSprite();
		pole.loadGraphic("assets/images/pole.png");
		pole.createRectangularBody();
		pole.body.position.x = 160 + 80 - 112;
		pole.body.position.y = 184 + 8;
		add(pole);
		
		add(text);
		
		timer = new FlxTimer();
		
		FlxG.camera.fade(FlxColor.BLACK, 1, true);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.R)
		{
			FlxNapeSpace.space.gravity.setxy(0, 980);
			timer.start(2, FadeOut);
		}
	}
	
	function FadeOut(timer:FlxTimer)
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, GoToGame);
	}
	
	function GoToGame()
	{
		FlxG.switchState(new PlayState());
	}
}
