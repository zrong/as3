////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  最后更新时间：2011-08-03
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.character
{

/**
 * 保存角色动作的所有可用Label
 */
public class ActionLabel 
{
	//----------------------------------------允许调用并支持返回调用的动作
	/**
	 * 被击中的动作
	 */
	public static const HIT:String = 'hit';

	/**
	 * 死亡的动作
	 */
	public static const DEAD:String = 'dead';

	/**
	 * 攻击别人的动作
	 */
	public static const ATTACK:String = 'attack';

	/**
	 * 释放技能的动作
	 */
	public static const SKILL:String = 'skill';
	
	//----------------------------------------允许调用，但不支持返回调用的动作
	/**
	 * 闪避的动作
	 */
	public static const MISS:String = 'miss';

	/**
	 * 90度站立的动作
	 */
	public static const STAND:String = 'stand';

	/**
	 * 跑动的动作
	 */
	public static const RUN:String = 'run';

	/**
	 * 45度站立的动作
	 */
	public static const STAND45:String = 'stand45';

	/**
	 * 45度站立，但没有影子
	 */
	public static const STAND45NO:String = 'stand45no';
}
}
