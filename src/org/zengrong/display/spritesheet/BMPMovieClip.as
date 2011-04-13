////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.display.BitmapData;
/**
 * 带有Label支持的BMPMovableSprite
 * @author zrong
 */
public class BMPMovieClip extends BMPMovableSprite
{
	public function BMPMovieClip()
	{
		super(null);
		_bmdGroup = {};
	}
	
	private var _state:String;
	private var _bmdGroup:Object;
	
	public function addLabel($label:String, $bmds:Vector.<BitmapData>):void
	{
		_bmdGroup[$label] = $bmds;
	}
}
}