package org.zengrong.flex.components
{
import flash.display.BitmapData;
import flash.events.Event;

import mx.graphics.BitmapFillMode;

import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;
import org.zengrong.flex.layouts.SpriteSheetCell;
import org.zengrong.flex.layouts.SpriteSheetLayoutBase;
import org.zengrong.flex.primitives.SpriteSheetBitmapImage;
import org.zengrong.net.SpriteSheetLoader;

import spark.components.Group;

/**
 * 自动解析SpriteSheet，根据SpriteSheetLayoutBase的子类提供cell的属性对SpriteSheet中的每个位图进行排列。支持平铺。
 * @author zrong
 * 创建时间：2012-02-06
 */
public class SpriteSheetGroup extends Group
{
	public function SpriteSheetGroup()
	{
		super();
	}
	
	protected var _source:*;
	protected var _metadataType:String;
	protected var _metadata:*;
	protected var _loader:SpriteSheetLoader;
	protected var _ss:SpriteSheet;
	
	/**
	 * SpriteSheet的metadata内容
	 */	
	public function get metadata():*
	{
		return _metadata;
	}

	/**
	 * SpriteSheet的metadata内容，值取决于metadataType
	 * @param $value
	 */	
	public function set metadata($value:*):void
	{
		_metadata = $value;
	}

	[Inspectable(category="General", enumeration="xml,json,binary,txt", defaultValue="xml")]
	
	public function get metadataType():String
	{
		return _metadataType;
	}

	public function set metadataType($value:String):void
	{
		_metadataType = $value;
	}
	
	/**
	 * 当前提供的SpriteSheet的地址或者内容
	 */	
	public function get source():Object
	{
		return _source;
	}

	public function set source($value:*):void
	{
		_source = $value;
	}


	public function get spriteSheetLayout():SpriteSheetLayoutBase
	{
		return this.layout as SpriteSheetLayoutBase;
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		_loader = getSpriteSheetLoader();
		_loader.addEventListener(Event.COMPLETE, handler_ssLoadComp);
		_loader.load(source as String, metadata, metadataType);
		trace(this.numElements+'个可视元素');
		//trace(spritetSheetLayout.cells.length+'个layoutCell');
	}
	
	/**
	 * 重写这个方法，返回SpriteSheetLoader的子类，以实现对其他文件格式的支持。
	 * @return 
	 */	
	protected function getSpriteSheetLoader():SpriteSheetLoader
	{
		return new SpriteSheetLoader();
	}
	
	protected function handler_ssLoadComp($evt:Event):void
	{
		_ss = _loader.getSpriteSheet();
		_ss.parseSheet();
		_ss.dispose();
		trace(_ss.metadata.toString());
		var __cells:Array = spriteSheetLayout.cells;
		var i:int=0;
		var __bmpi:SpriteSheetBitmapImage;
		if(__cells && __cells.length>0)
		{
			var __cell:SpriteSheetCell = null;
			var __source:BitmapData = null;
			for (i= 0;  i< __cells.length; i++) 
			{
				__cell = __cells[i];
				trace('__cell.index:', __cell.index);
				if(__cell.index>-1)
					__source = _ss.getBMDByIndex(__cell.index);
				else if(__cell.name)
					__source = _ss.getBMDByName(__cell.name);
				else
					__source = _ss.getBMDByIndex(i);
				__bmpi = new SpriteSheetBitmapImage();
				__bmpi.source = __source;
				__bmpi.cell = __cell;
				__bmpi.fillMode = __cell.fillMode?BitmapFillMode.REPEAT:BitmapFillMode.CLIP;
				this.addElement(__bmpi);
			}
		}
		else
		{
			for(i=0;i<_ss.metadata.totalFrame;i++)
			{
				__bmpi = new SpriteSheetBitmapImage();
				__bmpi.source = _ss.getBMDByIndex(i);
				this.addElement(__bmpi);
			}
		}
		trace('载入完毕');
	}
}
}