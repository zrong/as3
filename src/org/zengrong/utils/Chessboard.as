////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-01-05
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * 计算战斗场景中的棋盘状站位，保存站位坐标的位置和使用情况。
	 * 在游戏的战斗场景中，经常需要计算如何站位。这个类根据提供的宽、高、行、列自动计算对应人数的站位坐标。
	 * 例如，2行4列的一个棋盘状站位，一共会计算12个坐标。这中间不仅有8个人的站位，还有当某一列仅出现1个人时的站位。
	 * 因为这1个人不应站在8个人位置中的某一个位置，而应该站在2行的中间，因此有独立的坐标。
	 * 这个类，只会计算战斗的一方的站位，如果需要两方的站位，就需要这个类的两个对象。
	 * 使用isLeft属性来确认这个站位属于哪一方。
	 * */
	public class Chessboard
	{
		/**
		 * 计算站位的总宽度
		 */		
		public static var WIDTH:int = 432;
		
		/**
		 *计算站位的总高度 
		 */
		public static var HEIGHT:int = 400;
		
		/**
		 * 计算站位的行数
		 */		
		public static var ROW:int = 3;
		
		/**
		 * 计算站位的列数
		 */		
		public static var COLUMN:int = 4;
		
		/**
		 * 每个人站位坐标的横向间距，间距自动计算
		 */		
		private static var H_GAP:int = 100;
		
		/**
		 * 每个人站位坐标的纵向间距，间距自动计算
		 */		
		private static var V_GAP:int = 130;
		
		private var _points:Object;	//保存坐标
		private var _pointUse:Object;	//保存坐标是否被使用
		
		private var _basePoint:Point;
		private var _isLeft:Boolean;
		//$ourpart, 是否是己方。如果是己方，坐标从右往左计算，否则就从左往右计算。因为己方总是站在左边的
		public function Chessboard($point:Point=null, $left:Boolean=true)
		{
			if(!$point)
				return;
			create($point, $left);
		}
		
		public function create($point:Point, $left:Boolean):void
		{
			if(!$point)
				throw new Error('要生成站位坐标，必须首先提供初始坐标！');
			_basePoint = $point;
			_isLeft = $left;
			H_GAP = WIDTH / COLUMN;
			_points = new Object();
			_pointUse = new Object();
			var __direction:int = _isLeft ? -1 : 1;
			//根据站位的行数生成坐标
			for(var i:int=1; i<=ROW; i++)
			{
				drawPoint(i, __direction);
			}
		}
		
		public function get isLeft():Boolean
		{
			return _isLeft;
		}
		
		public function set isLeft($bool:Boolean):void
		{
			_isLeft = $bool;
		}
		
		public function get points():Object
		{
			return _points;
		}
		
		public function get pointUse():Object
		{
			return _pointUse;
		}
		
		public function setPoints($point:Object):void
		{
			_points = {};
			for(var __key:String in $point)
			{
				_points[__key] = new Point($point[__key].x, $point[__key].y);
			}
		}
		
		public function setPointUse($pointUse:Object):void
		{
			_pointUse = {};
			for(var __key:String in $pointUse)
			{
				_pointUse[__key] = $pointUse[__key];
			}
		}
		
		//返回一个格子是否被使用
		public function getUsed($index:String):Boolean
		{
			throwIndexError($index.length);
			return _pointUse[$index];
		}
		
		//设置一个格子已经使用
		public function setUsed($index:String):void
		{
			throwIndexError($index.length);
			_pointUse[$index] = true;
		}
		
		//清除一个格子，使其可用
		public function clearUsed($index:String):void
		{
			throwIndexError($index.length);
			_pointUse[$index] = false;
		}
		
		//清除所有格子
		public function clearAllUsed():void
		{
			for(var __key:String in _pointUse)
			{
				_pointUse[__key] = false;
			}
		}
		
		//获取一个坐标
		public function getPoint($index:String):Point
		{
			throwIndexError($index.length);
			return _points[$index];
		}
		
		private function throwIndexError($length:int):void
		{
			if($length != 3)
				throw new Error('站位索引必须为3位数！');
		}
		
		/**
		 * 计算“一批”站位坐标
		 * 如果总站位有2行，那么drawPoint会被调用2次，如果有3行，则会调用3次。每次调用，都会生成对应的行数的所有坐标。
		 * 以2行4列为例，第1次调用，会生成每列只有1人的时候的4个坐标；第2次调用，会生成每列有2个人的时候的8个坐标。
		 * @param $row 当前正在计算的行索引
		 * @param $direction x计算方向，-1为从右到左，1为从左到右
		 */		
		private function drawPoint($row:int, $direction:int=1):void
		{
			//垂直分隔的值根据行数来确定
			V_GAP = HEIGHT / $row;
			//计算“这次”生成一共有几个坐标
			var __count:int = COLUMN*$row;
			var __points:Array = [];
			for(var i:int=0; i<__count; i++)
			{
				//列索引，以站在右边的一方为例。左边第1列为0，第2列为1，以此类推。
				var __c:int = int(i%COLUMN);
				//行索引，0代表这一列中站立的第1个人的坐标，1代表这一列中站立的第2个人的坐标，以此类推。
				var __r:int = int(i/COLUMN);
				
				/*基于基准站位点计算坐标。
				如果本方站在右边，基准站位点是位于本方站位方块左上角的那一点。因为右边的x偏移值是整数
				如果本方站在左边，基准站位点就是位于本方站位方块右上角的那一点。因为左边的x偏移值是负数*/
				var __x:Number = _basePoint.x + $direction*(H_GAP/2 + H_GAP*__c);
				var __y:Number = _basePoint.y + getOffsetY($row, __r);
				
				var __point:Point = new Point(__x, __y);
				//生成一个3位的坐标索引值，第1位是当前计算的这一批坐标的行数量。第2、3位详见__c和__r的注释
				var __pointKey:String = $row + '' + __c + '' + __r; 
				_points[__pointKey] = __point;
				//默认所有的站位点都没有被使用
				_pointUse[__pointKey] = false;
			}
		}
		
		/**
		 * 计算坐标的y值偏移量
		 * @param $row 行索引
		 * @param $rowIndex 一行中站立的人的索引，详见drawPoint中的__r注释
		 */		
		private function getOffsetY($row:int, $rowIndex:int):Number
		{
			var __isOddLine:Boolean = Boolean($row%2);
			//每行与中心线的间隔初始值
			//如果行数是奇数的话，第一行在中间线上，每行与第一行的间隔，就不需要加上行高的一半
			//如果行数是偶数的话，第一行不在中间线上，第一行坐标为中间线坐标减去行高的一半；第二行则为中间线坐标加上行高的一半
			var __centerDist:Number;
			//坐标是应该基于中间线向上还是应该向下，负值为向上（y值减），正值为向下（y值加）
			var __pn:int;
			//基于中心线应该偏移的倍数
			var __vy:int;
			if(__isOddLine)
			{
				//奇数行不需要计算间隔
				__centerDist = 0;
				//奇数行第一行为中心线，那么第2、3行与中心线的距离为1倍行高，4、5行为2倍行高……
				__vy = Math.ceil($rowIndex/2);
				//奇数行，因为第一行在中心线上，因此当行索引为奇数的时候，坐标应该向下，否则向上
				__pn = Boolean($rowIndex%2) ? -1 : 1;
				if($rowIndex == 0)
					__pn = 0;
			}
			else
			{
				//偶数行的间隔初始值为行高的一半
				__centerDist = V_GAP / 2;
				//偶数行第一行和第二行中中间为中心线，那么第1、2行与中心线的距离为行高的一半，3、4行为1倍行高，5、6行为2倍行高……
				__vy = Math.floor($rowIndex/2);
				//偶数行，当行索引为奇数的时候，坐标应该向上，否则向下
				__pn = Boolean($rowIndex%2) ? 1 : -1;
			}
			return __pn*(__centerDist + V_GAP * __vy); 
		}
	}
}