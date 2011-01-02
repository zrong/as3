////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-01-02
//	说明：本组件参照Keith Peters的Minimalcomps组件写成，修改、使用或继承Minimalcal源码
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.controls
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import org.zengrong.controls.supportClasses.DisplayObjectButtonBase;

/**
 * 根据提供的Class生成按钮。提供的Class必须是显示对象的Class，例如嵌入的图像文件、MovieClip等等。 
 * @author zrong
 */
public class ClassButton extends DisplayObjectButtonBase
{
	public function ClassButton($class:Class, $parent:DisplayObjectContainer = null, $xpos:Number = 0, $ypos:Number =  0, $defaultHandler:Function = null)
	{
		_upState = DisplayObject(new $class);
		_colorless = true;
		super($parent, $xpos, $ypos, $defaultHandler);
		setSize(_upState.width, _upState.height);
	}
	
}
}