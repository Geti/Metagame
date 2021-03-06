package com.game.Metagame
{
	import org.flixel.*;

	public class Player extends DynamicObject
	{
	
		[Embed(source="../../../data/robot.png")] private var ImgPlayer:Class;
		
		private var keys:Object;
		private var inputThrust:FlxPoint;
		private var airThrustMultiplier:Number;
		private var crouching:Boolean;
		private var rolling:Boolean;
		private var rollThrustMultiplier:Number;
		private var rollBounce:Number;
		private var crouchThrustMultiplier:Number;
		private var crouchJumpMultiplier:Number;
		private var rollDrag:Number;
		private var jumping:Boolean;
		private var jumpTimer:Number; //variable that times the length of each jump
		private var jumpDuration:Number;
		private var gibs:FlxEmitter; //hooray! maybe use more than one, for more cinematic deaths.
		
		public var travel:Object;
		
		public function Player(X:int,Y:int,lvl:Level)
		{
			super(X,Y,lvl);
			loadGraphic(ImgPlayer,true,true,40,40);
						
			//Travel, an object with BG/FG booleans to indicate ability to travel.
			travel = new Object();
			travel.FG = false;
			travel.BG = false;
			
			//input. This should be expanded later,
			//I'm just doing it like this with a generic object so I don't need to go through and find all explicit references later.
			keys = new Object();
			keys.left="LEFT";
			keys.right="RIGHT"
			keys.jump="Z";
			keys.crouch="X";
			keys.forward="UP";
			keys.backward="DOWN"; //for once we've got 3d.
			
			//basic player physics
			inputThrust = new FlxPoint(2/3,5); //running and jump input thrust
			airThrustMultiplier = 1/3;
			crouchThrustMultiplier = 0.3;
			crouchJumpMultiplier = 0.5; //don't know what happened here, I don't rememeber touching it. Back to 0.5
			rollBounce = 0.5; //tweaked to feel less like rubber :P
			rollThrustMultiplier = 0.15;
			angularDrag = 0.1
			groundDrag = 0.85;
			rollDrag = 0.98;
			airDrag = 0.95;
			//1-gD=(1-aD)/aTM should roughly hold for smooth running jumps.
			jumpDuration = 25; //minimum needed to jump up screens w/o walljump!
			gravity = 0.3;
			maxVelocity.x = 10;
			maxVelocity.y = 10; //maybe this should be lower? it's pretty exteme..
						
			//the player will have several states (standing, crouching, rolling etc) with different bounding boxes
			//this probably shouldn't be a generic object
			boxData = new Object();
			boxData.stand = {w:15,h:30,ox:12,oy:6}; //these changed due to the graphical changes
			boxData.crouch = {w:15,h:15,ox:12,oy:21};
			boxData.roll = {w:15,h:15,ox:12,oy:20};
			
			//set bounding box
			x -= width/2;
			y -= height; //the player's starting point should refer to the bottom of the sprite
			changeBoxes("stand");
			
			//animations
			addAnimation("idle", [0]);
			addAnimation("run", [1, 2, 3, 5, 6, 7], 0.2);
			addAnimation("jumpup", [2,3],0.07,false);
			addAnimation("jumpdown", [6,7],0.07,false);
			addAnimation("crouch", [4]);
			addAnimation("roll", [4]); //need actual sprites for roll
		}
		
		override public function update():void
		{
			
			//MOVEMENT
			//drag
			velocity.x *= rolling?rollDrag:onFloor?groundDrag:airDrag; //technically, this should be based on the force of gravity, but that would feel weird.
			velocity.y *= rolling?rollDrag:airDrag
			//surface friction for the vertical component seems unfun.
			//for now I've disabled vertical drag totally because it caused problems with variable-height jumping.
			
			//input

			if(FlxG.keys.pressed(keys.crouch))
			{
				if(!crouching && !rolling)
				{
					if(Math.abs(velocity.x) > 0.7*inputThrust.x/(1-groundDrag))
					{
						//player is travelling at 0.7 of max natural running speed;roll
						changeBoxes("roll");
						angle = 90; //indicator that this is roll not crouch
						angularVelocity = 360*velocity.x/(Math.PI*height); //start off with some spin cos it looks better
						origin.y = 28; //i don't have an animation yet so i need to use FlxSprite.angle. This should be removed later.
						rolling = true;
					}
					else
					{
						changeBoxes("crouch");
						crouching = true;
					}
				}
			}
			else
			{
				changeBoxes("stand");
				angle = 0;
				angularVelocity = 0;
				crouching=false;
				rolling=false;
			}
			
			var thrustDir:int = int(FlxG.keys.pressed(keys.right))-int(FlxG.keys.pressed(keys.left)); //1 is right, -1 is left.
			if (thrustDir != 0)
			{
				if(!rolling)facing = thrustDir>0?RIGHT:LEFT;
				acceleration.x += thrustDir*inputThrust.x;
				if (!onFloor)
					acceleration.x *= airThrustMultiplier; //less thrust in the air
				if(crouching)
					acceleration.x *= crouchThrustMultiplier; //less thrust while crouching
				if(rolling)
					acceleration.x *= rollThrustMultiplier; //less thrust while rolling
			}
			if(FlxG.keys.justPressed(keys.jump) && onFloor && !rolling)
			{
				acceleration.y -= inputThrust.y*(crouching ? crouchJumpMultiplier : 1);
				jumpTimer = 1; //after this timer elapses (gets to zero), the player can no longer control the vertical of the jump
				jumping = true;
			}
			if (jumping) //tick down and such
			{
				jumpTimer -= 1/jumpDuration;
				if (FlxG.keys.justReleased(keys.jump) || jumpTimer < 0)
					jumping = false;
			}
			if(onTop){
				jumping=false;
			}
			if (FlxG.keys.pressed(keys.jump) && jumping)
			{
				if(jumpTimer>0)acceleration.y -= gravity;//+inputThrust.y*Math.pow(jumpTimer,2); //this is unphysical. Its purpose is to allow variable height jumps.
			}
			
			if (FlxG.keys.pressed(keys.backward) && travel.FG && level.curscreen.position[2] > 0)
			{
				level.curscreen.objects.remove(this); //remove and splice out the player
				level.curscreen = level.screenArray[level.curscreen.position[0]][level.curscreen.position[1]][level.curscreen.position[2]-1];
				level.curscreen.objects.add(this); //put the player into the new currentscreen's objects!
			}
			if (FlxG.keys.pressed(keys.forward) && travel.BG && level.curscreen.position[2] < level.dimensions[2] - 1)
			{
				level.curscreen.objects.remove(this); //remove and splice out the player
				level.curscreen = level.screenArray[level.curscreen.position[0]][level.curscreen.position[1]][level.curscreen.position[2]+1];
				level.curscreen.objects.add(this); //put the player into the new currentscreen's objects!
			}
			travel.FG = false;
			travel.BG = false;
			
			//TODO: Aiming
			
			//We're not calling super.update().
			//The reason is that we want to collide between updateMotion and updateAnimation,
			//so we need to trigger them manually.
			
			super.updateMotion();
			onLeft=onRight=onTop=false;
			collideVsLevel();
			if (rolling){
				//rotate the sprite
				if(onFloor)
				{
					angularVelocity = 360*velocity.x/(Math.PI*height);
				}
				else if(onTop)
				{
					angularVelocity = -360*velocity.x/(Math.PI*height);
				}
				if(onLeft)
				{
					angularVelocity = 360*velocity.y/(Math.PI*height);
				}
				else if(onRight)
				{
					angularVelocity = -360*velocity.y/(Math.PI*height);
				}
			}
			
			acceleration.x = 0;
			acceleration.y = gravity;
			//this acceleration reset means player.update() must come after every other object updates (which would make sense, anyway).
			//If we were to prevent this from being required we'd have to have separate impulse variables.
			
			//ANIMATION
			if(crouching)
			{
				play("crouch");
			}
			else if(rolling)
			{
				play("roll");
			}
			else if(velocity.y < 0)
			{
				play("jumpup");
			}
			else if(velocity.y > 0)
			{
				play("jumpdown");
			}
			else if(thrustDir == 0)
			{
				play("idle");
			}
			else
			{
				play("run");
			}
			
			//UPDATE ANIMATION
			super.updateAnimation();
			super.updateFlickering();
		}
		
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void
		{
			//if(velocity.y > 50)
				//FlxG.play(SndLand); ---------------------------------------------------ADD LANDING SOUND
			jumping = false;
			jumpTimer = 0;
			var velCache:Number = velocity.y; //velocity gets killed when hitting an object, so for bounce we need to cache it.
			super.hitBottom(Contact,Velocity);
			if(rolling)
			{
				velocity.y = -velCache*rollBounce;
			}
		}
		override public function hitSide(Contact:FlxObject,Velocity:Number):void
		{
			var velCache:Number = velocity.x; //velocity gets killed when hitting an object, so for bounce we need to cache it.
			if(!fixed)
				velocity.x = Velocity;
			
			if(rolling)
			{
				velocity.x = -velCache*rollBounce;
			}
		}
	}
}
