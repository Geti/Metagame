package com.game.Metagame
{
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		//[Embed(source="../../../data/map.txt",mimeType="application/octet-stream")] private var TxtMap:Class;
		[Embed(source="../../../data/04B03.TTF", fontName="F04B", embedAsCFF="false", mimeType="application/x-font-truetype")]
		private var F04:Class; //EMBED THE FONT
		//TODO SOUNDS
		
		//VARIABLES
		public var level:Level;
		
		override public function create():void
		{
			var data:String = "#test level#Geti#2|2|2#00000000000000000000000000000000000000000000000000111111000000000000000000011111000000000000000000001110000000000000000000000110000000000000000000000011000000011000000000000001111111111000011000000000111111111000001111111000011111111111000111111111111111111111100001111111111111111000010000000011111111100000000000000000111111110000000000000000011111111000000000011110001111111110011111111111111111111111001111111111111111111/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000/|11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100001111111111111110011110000000001111111100000111100000000001111110000000000000000000111111111111111111100000011111111111111111110001111111111111111111111001111111/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220000000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000/|11110011111111111111111111111001111111100000000000111001111000000000000000011100111000000000000000001110000000000000000000001111000000000000000000000111110000000000000001111111111100000000000111111111111111100000011111111111111111111000001111100001111111111000000000000000001111111000000000000000000111000000000000000000000011000000000000000000000001100000000000111100000000011111111111111110110000001111111111111111111111111/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000/|11111111111111110011111111111111111111110001111111111111111111111000111111111111111111111100111111111111111111100000000001111111111110000000000000011111111110000011111000011111111000000001111111011111111100011000000111101111111110011111000000110111111111000100000000011001111111110000000011111100111111111100000111111110111111111000000000000111011111111100000000000000001111111111111111111000000111111111111111111111111111111/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220000000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000/|00000000000000000000000000000000000000000000000001000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000111100000000000000000011111110000000000000000000111111000000000000011000000001111000111110000000000000011111111111000000000000001111111111111000000000000111111111111111111100000011111111100000011110000011111111100000000000000001111111110000000000000011111111111110011111111111111/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/|//|11111111100111111111111110001110000011111111111111000111000001111111111111100001000011111100000000011000000001110000000000001100000001111000011100000110001100000000111110000011100000000000011111100111111000011111100111000011111111111111000000000011111111110001110000000001111111110000110000001111111111000000000000011111111111000001100000011111111111000000110011111111111111100001111111111111111111111111111111111111111111111/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/|//#120|100|1|1|1#";
			
			//TODO: LOADING FROM OTHER PLACES
			
			//no mouse in game
			//FlxG.mouse.hide();
			
			level = new Level(data);
			add(level);
			
			//unfade
			FlxG.flash.start(0xff000000,20);
			
			//track the number of plays in a save
			var save:FlxSave = new FlxSave();
			if(save.bind("Metagame"))
			{
				if(save.data.plays == null)
					save.data.plays = 0;
				else
					save.data.plays++;
				FlxG.log("Number of plays: "+save.data.plays);
			}
		}

		override public function update():void
		{
			//GAME LOGIC HERE
			super.update(); //I need to call this earlier than collide to stop "squishy" intersections.
		}

	}
}
