package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;
import flash.geom.Point;

/**
 * SpriteSheetMetadata的包装器的基类
 * 
 * @author zrong (http://zengrong.net)
 * 创建日期：2013-4-6
 */
public class SpriteSheetMetadataWrapper implements ISpriteSheetMetadata
{
	public function SpriteSheetMetadataWrapper($meta:ISpriteSheetMetadata)
	{
		_metadata = $meta;
	}
	
	protected var _metadata:ISpriteSheetMetadata;
	
	public function get type():String
	{
		return _metadata.type;
	}
	
	public function set type($value:String):void
	{
		_metadata.type = $value;
	}
	
	public function get hasLabel():Boolean
	{
		return _metadata.hasLabel;
	}
	
	public function set hasLabel($value:Boolean):void
	{
		_metadata.hasLabel = $value;
	}
	
	public function get hasName():Boolean
	{
		return _metadata.hasName;
	}
	
	public function set hasName($value:Boolean):void
	{
		_metadata.hasName = $value;
	}
	
	public function get maskType():int
	{
		return _metadata.maskType;
	}
	
	public function set maskType($value:int):void
	{
		_metadata.maskType = $value;
	}
	
	public function get labels():Vector.<String>
	{
		return _metadata.labels;
	}
	
	public function set labels($value:Vector.<String>):void
	{
		_metadata.labels = $value;
	}
	
	public function get labelsFrame():Object
	{
		return _metadata.labelsFrame;
	}
	
	public function set labelsFrame($value:Object):void
	{
		_metadata.labelsFrame = $value;
	}
	
	public function get names():Vector.<String>
	{
		return _metadata.names;
	}
	
	public function set names($value:Vector.<String>):void
	{
		_metadata.names = $value;
	}
	
	public function get namesIndex():Object
	{
		return _metadata.namesIndex;
	}
	
	public function set namesIndex($value:Object):void
	{
		_metadata.namesIndex = $value;
	}
	
	public function get frameRects():Vector.<Rectangle>
	{
		return _metadata.frameRects;
	}
	
	public function set frameRects($value:Vector.<Rectangle>):void
	{
		_metadata.frameRects = $value;
	}
	
	public function get originalFrameRects():Vector.<Rectangle>
	{
		return _metadata.originalFrameRects;
	}
	
	public function set originalFrameRects($value:Vector.<Rectangle>):void
	{
		_metadata.originalFrameRects = $value;
	}
	
	public function get anchorPoints():Vector.<Point>
	{
		return _metadata.anchorPoints;
	}
	
	public function set anchorPoints($value:Vector.<Point>):void
	{
		_metadata.anchorPoints = $value;
	}
	
	public function get offsetPoints():Vector.<Point>
	{
		return _metadata.offsetPoints;
	}
	
	public function set offsetPoints($value:Vector.<Point>):void
	{
		_metadata.offsetPoints = $value;
	}
	
	public function get totalFrame():int
	{
		return _metadata.totalFrame;
	}
	
	public function setup($force:Boolean=false):void
	{
		_metadata.setup($force);
	}
	
	public function clone():ISpriteSheetMetadata
	{
		return _metadata.clone();
	}
	
	public function destroy():void
	{
		_metadata.destroy();
	}
	
	public function addLabel($labelName:String, $labelFrame:Array):void
	{
		_metadata.addLabel($labelName, $labelFrame);
	}
	
	public function setLabels($hasLabel:Boolean, $labels:Object=null):void
	{
		_metadata.setLabels($hasLabel, $labels);
	}
	
	public function addFrame($sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null, $anchorPoint:Point=null, $offsetPoint:Point=null):void
	{
		_metadata.addFrame($sizeRect, $originalRect, $name, $anchorPoint, $offsetPoint);
	}
	
	public function addFrameAt($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null, $anchorPoint:Point=null, $offsetPoint:Point=null):void
	{
		_metadata.addFrameAt($index, $sizeRect, $originalRect, $name, $anchorPoint, $offsetPoint);
	}
	
	public function removeFrameAt($index:int):void
	{
		_metadata.removeFrameAt($index);
	}
	
	/**
	 * @inheritDoc
	 */	
	public function getFrameName($includeName:Boolean, $index:int):String
	{
		return _metadata.getFrameName($includeName, $index);
	}
	
	/**
	 * @inheritDoc
	 */	
	public function parse($value:*):ISpriteSheetMetadata
	{
		return null;
	}
	
	/**
	 * @inheritDoc
	 */
	public function objectify($isSimple:Boolean=false, $includeName:Boolean=true, ...$args):*
	{
		return null;
	}
	
	public function toString():String
	{
		return String(objectify(true, true));
	}
}
}