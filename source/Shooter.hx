package;

import flixel.group.FlxGroup.FlxTypedGroup;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;

import flixel.FlxG;

import flixel.math.FlxVector;

/**
 * ...
 * @author Gamepopper
 */
class Shooter extends FlxTypedGroup<FlxNapeSprite>
{	
	public function new(player:CbType) 
	{
		super(10);
		
		for (i in 0...maxSize)
		{
			var spr = new FlxNapeSprite(0, -180);
			spr.loadGraphic("assets/images/rock.png", true, 4, 4);
			
			spr.createCircularBody(4);
			spr.body.isBullet = true;
			spr.setBodyMaterial(1, 0, 0, 4);
			var cbType = new CbType();
			var interactionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, cbType, player, HitSound);
			spr.body.cbTypes.add(cbType);
			spr.kill();
			
			add(spr);
			FlxNapeSpace.space.listeners.add(interactionListener);
		}		
	}
	
	public function Fire(strength:Float = 4.5)
	{
		var spr = recycle(FlxNapeSprite);
		
		spr.animation.frameIndex = FlxG.random.int(0, 4);
		
		var angle:Float = 0.0;
		var impulse:Float = 500.0;
		spr.body.position.y = 200;
		
		if (FlxG.random.bool())
		{
			spr.body.position.x = 150;
			angle = -75;
		}
		else
		{
			spr.body.position.x = 330;
			angle = 255;
		}
		
		spr.body.velocity.setxy(
			impulse * Math.cos(angle * 3.14 / 180),
			impulse * Math.sin(angle * 3.14 / 180));
			
		spr.setBodyMaterial(1, 0, 0, strength);		
			
		spr.body.angularVel = 5;
		
		spr.revive();
	}
	
	function HitSound(callback:InteractionCallback)
	{
		#if !flash
		FlxG.sound.play(AssetPaths.hit__ogg);
		#end
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);		
		forEachAlive(touchGround);
	}
	
	function touchGround(spr:FlxNapeSprite)
	{
		if (spr.body.position.y > FlxG.height - 8)
		{
			spr.body.position.setxy(0, -180);
			spr.kill();
		}
	}
}