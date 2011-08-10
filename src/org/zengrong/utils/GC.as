////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2011-8-10
////////////////////////////////////////////////////////////////////////////////

package org.zengrong.utils
{
import flash.net.LocalConnection;

/**
 * 执行强制垃圾回收
 * 每次执行约耗费200ms，若引用关系复杂则更甚，慎用慎用
 * @author zrong
 */
public static function GC():void
{
	//连续两次连接同一地址会抛出异常，Flash Player在遇到异常的时候会强制进行垃圾回收
	//使用LocalConnection的原因是这个操作很不常用，不易发生冲突
	start(); start();
	function start ():void { try { new LocalConnection().connect('GC'); } catch (e:Error) {} }
}
}