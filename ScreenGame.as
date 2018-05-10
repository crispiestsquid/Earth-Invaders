﻿package {	import flash.display.MovieClip;	import flash.events.Event;	import flash.utils.getDefinitionByName;	import flash.utils.getQualifiedClassName;	import flash.geom.Point;	import flash.media.SoundChannel;	import flash.events.MouseEvent;	public class ScreenGame extends MovieClip	{		private var _enemies:Array;		private var _numOfEnemies:Number;		private var _blocks:Array;		private var _ranged:Array;		private var upgradeScreen:ScreenUpgrade;		private var _soundChannel:SoundChannel;		private var _cannonBoom:cannonboom;		private var _knightAttack:knightattack;		private var _mouseClick:mouseclick;		private var _subtractNum:Number;		public function ScreenGame()		{			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);		}		private function onAddedToStage(e:Event):void		{			stage.focus = this;			// set variables			_soundChannel = new SoundChannel();			_cannonBoom = new cannonboom();			_knightAttack = new knightattack();			_mouseClick = new mouseclick();			_enemies = new Array();			_numOfEnemies = 10;			_blocks = new Array();			_ranged = new Array();			_subtractNum = 200;			// set the ranged to empty			rangedDrop1.ranged1.gotoAndStop("empty");			rangedDrop2.ranged1.gotoAndStop("empty");			// push the blocks into the array;			_blocks.push(blockDrop1.getChildAt(1) as MovieClip);			_blocks.push(blockDrop2.getChildAt(1) as MovieClip);			// push the ranged into the array;			/*_ranged.push(rangedDrop1.getChildAt(1) as MovieClip);			_ranged.push(rangedDrop2.getChildAt(1) as MovieClip);*/			// add listeners;			stage.addEventListener(MouseEvent.CLICK, onClick);			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);			addEventListener("advance", onAdvance);			addEventListener("rangedFire", onRangedFire);			addEventListener("explosionDone", onExplosionDone);			addEventListener("testCannonball", onTestCannonball);			addEventListener("gameOver", onGameOver);			addEventListener(Event.ENTER_FRAME, Update);			//place enemies			enemyPlacement(_subtractNum);		}		private function onRemovedFromStage(e:Event):void		{			// remove listeners			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);			removeEventListener("advance", onAdvance);			removeEventListener(Event.ENTER_FRAME, Update);			stage.removeEventListener(MouseEvent.CLICK, onClick);		}		private function onClick(e:MouseEvent):void		{			_soundChannel = _mouseClick.play();		}		// function for placing all the enemies		private function enemyPlacement(subtractAmount:Number):void		{			var numOfColumns:Number = 5;			var spacer:Number = 22;			var count:Number = 0;			var enemy:Soldier;			var subtract:Number = subtractAmount;			for (var i:Number = 0; i < _numOfEnemies; i++)			{				if (count < 5)				{					enemy = new Soldier("archer");				}				else if (count >= 5 && count < 15)				{					enemy = new Soldier("strong");				}				else if (count >= 15 && count < 20)				{					enemy = new Soldier("regular");				}				else if (count >= 20)				{					enemy = new Soldier("weak");				}				enemy.x = spacer + (i % numOfColumns) * (enemy.width + spacer);				enemy.y = spacer + Math.floor(i / numOfColumns) * (enemy.height + spacer) - subtract;				_enemies.push(enemy);				addChild(enemy);				count++;			}		}		// function to make all enemies advance at once, as soon as one reaches the edge		private function onAdvance(e:Event):void		{			// loop through all enemies			for (var i:Number = 0; i < _enemies.length; i ++)			{				// run the advance code for the current enemy				_enemies[i].advance();			}		}		// enter frame function		private function Update(e:Event):void		{			// check to see if the wave of enemies is gone			{				if (_enemies.length < 1)				{					for (var i:Number = 0; i < _ranged.length; i ++)					{						_ranged[i].canShoot = false;					}					_blocks.length = 0;					_ranged.length = 0;					removeEventListener(Event.ENTER_FRAME, Update);					upgrade();				}			}		};		private function upgrade():void		{			upgradeScreen = new ScreenUpgrade();			addChild(upgradeScreen);		}		public function removeUpgrade():void		{			// set stage focus to the game screen			stage.focus = this;			// push the blocks into the array			_blocks.push(blockDrop1.getChildAt(1) as MovieClip);			_blocks.push(blockDrop2.getChildAt(1) as MovieClip);			// push the ranged into the array;			_ranged.push(rangedDrop1.getChildAt(1) as MovieClip);			_ranged.push(rangedDrop2.getChildAt(1) as MovieClip);			for (var i:Number = 0; i < _ranged.length; i ++)			{				_ranged[i].canShoot = true;			}			// remove the upgrade screen			removeChild(upgradeScreen);			upgradeScreen = null;			addEventListener(Event.ENTER_FRAME, Update);			_numOfEnemies += 5;			_subtractNum += 50;			enemyPlacement(_subtractNum);		}		// function for adding bullets from ranged		private function onRangedFire(e:Event):void		{			var type:String = e.target.type;			var ranged:MovieClip = e.target as MovieClip;			var localPoint:Point = new Point(ranged.x,ranged.y);			var rangedG:Point = new Point(ranged.parent.localToGlobal(localPoint).x,ranged.parent.localToGlobal(localPoint).y);			if (type == "archers")			{				// calculate the angle of the archers in radians				var _angle1:Number = ranged.rotation * Math.PI / 180;				// calculate the arrow's velocity on x and y				var _arrowVx1:Number = Math.cos(_angle1) * ranged.arrowSpeed;				var _arrowVy1:Number = Math.sin(_angle1) * ranged.arrowSpeed;				// calculate arrow start position				var _arrowStartX1:Number = (rangedG.x) + ranged.radius * Math.cos(_angle1);				var _arrowStartY1:Number = (rangedG.y) + ranged.radius * Math.sin(_angle1);				// actually create the 1st arrow				this.addChild(new Arrow(_arrowVx1, _arrowVy1, _arrowStartX1, _arrowStartY1, ranged.rotation, "rangedA"));				// calculate the angle of the player in radians;				var _angle2:Number = -70 * Math.PI / 180;				// calculate the arrow's velocity on x and y				var _arrowVx2:Number = Math.cos(_angle2) * ranged.arrowSpeed;				var _arrowVy2:Number = Math.sin(_angle2) * ranged.arrowSpeed;				// calculate arrow start position				var _arrowStartX2:Number = (rangedG.x) + ranged.radius * Math.cos(_angle2);				var _arrowStartY2:Number = (rangedG.y) + ranged.radius * Math.sin(_angle2);				// actually create the 2nd arrow				this.addChild(new Arrow(_arrowVx2, _arrowVy2, _arrowStartX2, _arrowStartY2, -70, "rangedA"));				// calculate the angle of the player in radians;				var _angle3:Number = -110 * Math.PI / 180;				// calculate the arrow's velocity on x and y				var _arrowVx3:Number = Math.cos(_angle3) * ranged.arrowSpeed;				var _arrowVy3:Number = Math.sin(_angle3) * ranged.arrowSpeed;				// calculate arrow start position				var _arrowStartX3:Number = (rangedG.x) + ranged.radius * Math.cos(_angle3);				var _arrowStartY3:Number = (rangedG.y) + ranged.radius * Math.sin(_angle3);				// actually create the 3rd arrow				this.addChild(new Arrow(_arrowVx3, _arrowVy3, _arrowStartX3, _arrowStartY3, -110, "rangedA"));			}			else if (type == "cannon")			{				// calculate the angle of the cannon in radians				var _angle:Number = ranged.rotation * Math.PI / 180;				// calculate the arrow's velocity on x and y				var _arrowVx:Number = Math.cos(_angle) * ranged.arrowSpeed;				var _arrowVy:Number = Math.sin(_angle) * ranged.arrowSpeed;				// calculate arrow's start position				var _arrowStartX:Number = (rangedG.x) + ranged.radius * Math.cos(_angle);				var _arrowStartY:Number = (rangedG.y) + ranged.radius * Math.sin(_angle);				// actually create the arrow				this.addChild(new Arrow(_arrowVx, _arrowVy, _arrowStartX, _arrowStartY, rotation, "rangedC"));			}		}		private function onExplosionDone(e:Event):void		{			var cannonball:MovieClip = e.target.parent as MovieClip;			removeChild(cannonball);			cannonball = null;		}		private function onTestCannonball(e:Event):void		{			var explosion:MovieClip = e.target as MovieClip;			for (var i:Number = 0; i < _enemies.length; i ++)			{				if (_enemies[i].hitTestObject(explosion))				{					// make enemy lose health					_enemies[i].hit(2);					// check if enemy health is 0;					if (_enemies[i].health < 1)					{						// remove enemy						removeChild(_enemies[i]);						_enemies[i] = null;						_enemies.splice(i, 1);					}				}			}		}		private function onGameOver(e:Event):void		{			var gameOver:ScreenLose = new ScreenLose();			MovieClip(parent).addChild(gameOver);			MovieClip(parent).removeChild(this);		}		// Public methods that other classes can use to;		// check for collisions with objects in the game		// allow arrows to check collision against enemies		public function checkCollisionWithEnemies(_arrow:MovieClip):void		{			for (var i:Number = 0; i < _enemies.length; i ++)			{				if (_enemies[i].hitTestPoint(_arrow.x,_arrow.y,true))				{					if (_arrow.type == "player" && player.arrowType == "strong")					{						// make enemy lose health						_enemies[i].hit(2);						// check if enemy health is 0;						if (_enemies[i].health < 1)						{							// remove enemy							removeChild(_enemies[i]);							_enemies[i] = null;							_enemies.splice(i, 1);						}						// remove arrow						removeChild(_arrow);						_arrow = null;						// stop checking						break;					}					else if (_arrow.type == "player" && player.arrowType == "penetrating")					{						// make enemy lose health						_enemies[i].hit(1);						// check if enemy health is 0;						if (_enemies[i].health < 1)						{							// remove enemy							removeChild(_enemies[i]);							_enemies[i] = null;							_enemies.splice(i, 1);						}						// stop checking						break;					}					if (_arrow.type == "player" || _arrow.type == "rangedA")					{						// make enemy lose health						_enemies[i].hit(1);						// check if enemy health is 0;						if (_enemies[i].health < 1)						{							// remove enemy							removeChild(_enemies[i]);							_enemies[i] = null;							_enemies.splice(i, 1);						}						// remove arrow						removeChild(_arrow);						_arrow = null;						// stop checking						break;					}					else if (_arrow.type == "rangedC")					{						_arrow.gotoAndPlay("explosion");						_soundChannel = _cannonBoom.play();						_arrow.exploded = true;						_arrow.vx = 0;						_arrow.vy = 0;					}				}			}		}		public function checkCollisionWithPlayer(object:MovieClip):void		{			if (object.hitTestObject(player))			{				var gameOver:ScreenLose = new ScreenLose();				MovieClip(parent).addChild(gameOver);				MovieClip(parent).removeChild(this);			}		}		public function checkCollisionWithBlocks(object:MovieClip):void		{			for (var i:Number = 0; i < _blocks.length; i ++)			{				if (getClass(object) == Arrow || getClass(object) == SoldierArrow)				{					if (object.hitTestObject(_blocks[i].hitbox))					{						// check blocks health						_blocks[i].hit();						if (_blocks[i].health < 1)						{							// remove block							_blocks[i].gotoAndStop("empty");							_blocks.splice(i, 1);						}						// remove arrow						removeChild(object);						object = null;						// stop checking						break;					}				}				else if (getClass(object) == Soldier)				{					if (_blocks[i].blockType == "knight" && _blocks[i].cool)					{						for (var j:Number = 0; j < _enemies.length; j ++)						{							if (object == _enemies[j] && _enemies[j].hitTestObject(_blocks[i].hitboxkill))							{								// cool the knight								_soundChannel = _knightAttack.play();								_blocks[i].knightCoolDown();								// make enemy lose health								_enemies[j].hit(1);								// check if enemy health is 0;								if (_enemies[j].health < 1)								{									// remove enemy									removeChild(_enemies[j]);									_enemies[j] = null;									_enemies.splice(j, 1);								}								// stop checking								break;							}						}					}				}			}		}		static function getClass(obj:MovieClip):Class		{			return Class(getDefinitionByName(getQualifiedClassName(obj)));		}	}}