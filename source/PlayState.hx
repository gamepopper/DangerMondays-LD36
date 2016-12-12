package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxVector;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.BodyType;

class PlayState extends FlxState
{
	var loo:FlxNapeSprite;
	var pole:FlxNapeSprite;
	
	var timeText:FlxText;
	var gameOver:FlxText;
	var wind:FlxSprite;
	
	var worker:FlxSprite;
	var arms:FlxSprite;
	
	var rocks:Shooter;
	
	var excrement:FlxEmitter;
	var leftWall:FlxSprite;
	var rightWall:FlxSprite;
	
	var fallen:Bool = false;
	var gustTimer:FlxTimer;
	var rockTimer:FlxTimer;
	var time:Float = 0;
	
	override public function create():Void
	{
		super.create();
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 980);
		var walls = FlxNapeSpace.createWalls(0, 0, 640, 0);
		var wallCollision:CbType = new CbType();
		walls.cbTypes.add(wallCollision);
		
		var background = new FlxSprite(0, 0, "assets/images/background.png");
		
		loo = new FlxNapeSprite();
		loo.loadGraphic("assets/images/portaloo.png");
		loo.createRectangularBody();
		loo.setBodyMaterial(.5, .5, .5, 1, 0.1);
		loo.body.position.x = 160 + 80;
		loo.body.position.y = 96;
		
		var looCollison:CbType = new CbType();
		loo.body.cbTypes.add(looCollison);
		
		setImpulseOfLoo(FlxG.random.int( 20, 30) * (FlxG.random.bool() ? 1 : -1));
		
		pole = new FlxNapeSprite();
		pole.loadGraphic("assets/images/pole.png");
		pole.createRectangularBody(0, 0, BodyType.KINEMATIC);
		pole.setBodyMaterial(0, 1, 1, 1, 1);
		pole.body.position.x = 160 + 80;
		pole.body.position.y = 184;
		
		rocks = new Shooter(looCollison);
		
		wind = new FlxSprite(160, 65);
		wind.loadGraphic("assets/images/gust.png", true, 160, 40);
		wind.animation.add("blowToRight", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 24, false, true);
		wind.animation.add("blowToLeft",  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 24, false);
		wind.visible = false;
		
		timeText = new FlxText(160, 20, 160, "", 12);
		timeText.alignment = FlxTextAlign.CENTER;
		
		gameOver = new FlxText(160, 35, 160, "Press R to Retry", 12);
		gameOver.alignment = FlxTextAlign.CENTER;
		
		var insideLoo:FlxSprite = new FlxSprite();
		insideLoo.loadGraphic("assets/images/insideloo.png");
		leftWall = new FlxSprite(0, 0);
		leftWall.makeGraphic(8, FlxG.height, FlxColor.TRANSPARENT);
		leftWall.immovable = true;
		rightWall = new FlxSprite(152, 0);
		rightWall.makeGraphic(8, FlxG.height, FlxColor.TRANSPARENT);
		rightWall.immovable = true;
		
		worker = new FlxSprite();
		worker.loadGraphic("assets/images/worker.png");
		arms = new FlxSprite(0, -10);
		arms.loadGraphic("assets/images/workerarms.png");
		
		excrement = new FlxEmitter();
		excrement.makeParticles(2, 2, FlxColor.BROWN, 100);
		excrement.setPosition(80, 175);
		excrement.launchAngle.set(250, 290);
		excrement.launchMode = FlxEmitterMode.CIRCLE;
		excrement.speed.set(150, 250);
		excrement.lifespan.set(1);
		excrement.allowCollisions = FlxObject.ANY;
		excrement.elasticity.set(0.5);
		
		add(background);
		add(pole);
		add(loo);
		add(rocks);
		add(timeText);
		add(gameOver);
		add(wind);
		add(leftWall);
		add(rightWall);
		add(insideLoo);
		add(arms);
		add(worker);
		add(excrement);
		
		gustTimer = new FlxTimer();
		gustTimer.start(FlxG.random.float(3, 8), gustOfWind);
		
		rockTimer = new FlxTimer();
		rockTimer.start(FlxG.random.float(5, 8), throwRocks);
		
		var interactionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, looCollison, wallCollision, CrashSound);
		FlxNapeSpace.space.listeners.add(interactionListener);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (!fallen)
		{
			time += elapsed;
			
			if (time < 10)
			{
				timeText.text = "0" + Math.floor(time) + ":" + (Std.int(time * 1000) % 1000);
			}
			else
			{
				timeText.text = Math.floor(time) + ":" + (Std.int(time * 1000) % 1000);
			}
		}
		else
		{
			var vector = new FlxVector(0, 200);
			vector.rotateByRadians(loo.body.rotation);
			vector.x *= -1;
			excrement.acceleration.set(vector.x, vector.y);
			FlxG.collide(excrement, leftWall);
			FlxG.collide(excrement, rightWall);
		}
		
		gameOver.visible = fallen;
		
		if (loo.body.position.y < pole.y)
		{
			if (FlxG.keys.pressed.LEFT)
			{
				setImpulseOfLoo( -10);
			}
			if (FlxG.keys.pressed.RIGHT)
			{
				setImpulseOfLoo( 10);		
			}
			
			if (FlxG.keys.justPressed.LEFT)
			{
				FlxTween.tween(worker, {x: -10}, 0.2);
			}
			else if (FlxG.keys.justPressed.RIGHT)
			{
				FlxTween.tween(worker, {x: 10}, 0.2);
			}
			else if (FlxG.keys.anyJustReleased(["LEFT", "RIGHT"]))
			{
				FlxTween.tween(worker, {x: 0}, 0.5);
			}
		}
		else if (!fallen)
		{
			fallen = true;
			excrement.start(false, 0.01);
		}
		
		if (FlxG.keys.justPressed.G)
		{
			gustOfWind(null);
		}
		
		if (FlxG.keys.justPressed.P)
		{
			rocks.Fire();
		}
		
		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState();
		}
	}
	
	function setImpulseOfLoo(amount:Int):Void
	{
		var vector = new FlxVector(amount, 0);
		vector.rotateByRadians(loo.body.rotation);
			
		var impulsePoint = new FlxVector(0, -32);
		impulsePoint.rotateByRadians(loo.body.rotation);
			
		loo.body.applyImpulse(new Vec2(vector.x, vector.y), new Vec2(impulsePoint.x, impulsePoint.y).add(loo.body.position));
	}
	
	function gustOfWind(timer:FlxTimer):Void
	{
		var impulse = FlxG.random.int(20, 30) + Math.ceil(time);
		var direction = FlxG.random.bool();
		
		wind.visible = true;
		
		if (direction)
			wind.animation.play("blowToLeft");
		else
			wind.animation.play("blowToRight");
			
			
		FlxG.sound.play(AssetPaths.wind__ogg);
		
		setImpulseOfLoo(direction ? impulse : -impulse);
		
		if (timer != null && !fallen)
			timer.start(FlxG.random.float(3, 8) - (time < 75 ? time / 20 : 3), gustOfWind);
	}
	
	function throwRocks(timer:FlxTimer):Void
	{
		rocks.Fire(4 + (time / 20));
		
		if (timer != null && !fallen)
			timer.start(FlxG.random.float(3, 8) - (time < 75 ? time / 5 : 5), throwRocks);
	}
	
	function CrashSound(callback:InteractionCallback)
	{
		FlxG.sound.play(AssetPaths.crash__ogg);
	}
}
