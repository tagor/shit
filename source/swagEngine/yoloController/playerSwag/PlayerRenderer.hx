package swagEngine.yoloController.playerSwag;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import swagEngine.swagHandler.Settings;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;

/**
 * ...
 * @author Sjoer van der Ploeg
 */

class PlayerRenderer extends FlxSprite
{
	private var timer:Timer = new Timer(1000);
	public var portalTimer:Timer = new Timer(100);
	
	public var abilities:AbilityManager;
	
	public var portaling:Bool = false;
	public var godmode:Bool = false;
	
	public function new(_x:Float = 0, _y:Float = 0, _shots:FlxGroup)
	{
		super(_x, _y);
		
		//loadGraphic("assets/animations/player.png", true, 64, 128);
		loadGraphic("assets/animations/playertest.png", true, 64, 128);
		
		x -= width * 0.25;
		y -= height;
		
		/*var framesArray = new Array();
			for (i in 0...19)
				framesArray[i] = i;
		animation.add("walking", framesArray, 30, true);
		
		var framesArray = new Array();
			for (i in 20...33)
				framesArray[i - 20] = i;
		animation.add("resting", framesArray, 5, true);
		*/
		
		
		var framesArray = new Array();
			for (i in 0...14)
				framesArray[i] = i + 133;
		animation.add("walking", framesArray, 20, true);
		
		var framesArray = new Array();
			for (i in 0...133)
				framesArray[i] = i;
		animation.add("resting", framesArray, 20, true);
		
		
		facing = FlxObject.RIGHT;
		
		collisonXDrag = true;
		solid = true;
		
		drag.x = Settings.drag * 2;
		drag.y = Settings.drag;
		
		acceleration.y = Settings.acceleration;
		acceleration.x = 0;
		
		maxVelocity.x = Settings.maxVelocity;
		maxVelocity.y = Settings.maxVelocity * 2;
		
		abilities = new AbilityManager(this, _shots);
		
		animation.play("resting");
		
		timer.addEventListener(TimerEvent.TIMER, healthUp);
		timer.start();
		
		portalTimer.addEventListener(TimerEvent.TIMER, didPortal);
	}
	
	private function healthUp(e)
	{
		if (health < 990) health += 10;
		else if (health >= 990) health = 1000;
	}
	
	private function didPortal(e)
	{
		portalTimer.stop();
		
		portaling = false;
	}
	
	override public function update(e:Float)			// NEED TO FIX THE UGLY IF BASED KEY INPUT
	{
		#if !FLX_NO_DEBUG
		if (godmode)	// GODMODE HACK
		{
			health = 1000;
			acceleration.y = 0;
			for (i in 0...abilities.cards.energy.length)
				abilities.cards.energy[i] = 1;
		} else if (!godmode) acceleration.y = Settings.acceleration;
		#end
		
		if (e == 0) return;
		
		if (portaling)	// PORTAL HACK
		{
			super.update(e);
			
			return;
		}
		
		acceleration.x = 0;
		
		if (FlxG.keys.justPressed.UP)
		{
			abilities.spades();
		}
		else if (FlxG.keys.justPressed.DOWN)
		{
			velocity.y += abilities.scaled ? 400 : 300;
		}
		
		if (FlxG.keys.pressed.LEFT)
		{
			flipX = true;
			facing = FlxObject.LEFT;
			
			velocity.x -= 100;
			animation.play("walking");
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			flipX = false;
			facing = FlxObject.RIGHT;
			
			velocity.x += 100;
			animation.play("walking");
		}
		else animation.play("resting");
		
		
		// ROTATE CARDS
		if (FlxG.keys.justPressed.Q)
			abilities.rotate(0);
			
		if (FlxG.keys.justPressed.W)
			abilities.rotate(1);
			
		if (FlxG.keys.justPressed.E)
			abilities.rotate(2);
			
		if (FlxG.keys.justPressed.R)		// Probably useless will never rotate spades? Maybe?
			abilities.rotate(3);
		
		// USE ABILITY
		if (FlxG.keys.justPressed.A)
			abilities.diamonds();
			
		if (FlxG.keys.justPressed.S)
			abilities.clubs();
			
		if (FlxG.keys.justPressed.D)
			abilities.hearts();
			
		if (FlxG.keys.justPressed.F)		// Probably useless space = spades
			abilities.spades();
		
		if (FlxG.keys.justPressed.I)
		{
			animation.curAnim.frameRate++;
			trace(animation.curAnim.frameRate);
		}
		else if (FlxG.keys.justPressed.K)
		{
			animation.curAnim.frameRate--;
			trace(animation.curAnim.frameRate);
		}
		
		if (FlxG.keys.justPressed.G)
			godmode = !godmode;
		
		super.update(e);
	}
	
	override public function destroy()
	{
		abilities.destroy();
		abilities = null;
		
		portaling = false;
		godmode = false;
		
		portalTimer.removeEventListener(TimerEvent.TIMER, didPortal);
		portalTimer = null;
		
		timer.removeEventListener(TimerEvent.TIMER, healthUp);
		portalTimer = null;
		
		super.destroy();
	}
}