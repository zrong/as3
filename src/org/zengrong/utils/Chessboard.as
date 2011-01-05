/**
 * 保存战斗场景中的棋盘状站位
 * */
package org.zengrong.utils
{
	import com.adobe.serialization.json.JSON;
	
	import flash.geom.Point;
	import flash.text.TextField;
	
	import mx.utils.ObjectUtil;
	
	public class Chessboard
	{
		public static var WIDTH:int = 432;
		public static var HEIGHT:int = 400;
		
		public static var ROW:int = 3;
		public static var COLUNM:int = 4;
		
		private static var H_GAP:int = 100;
		private static var V_GAP:int = 130;
		
		private var _points:Object;		//保存坐标
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
			H_GAP = WIDTH / COLUNM;
			_points = new Object();
			_pointUse = new Object();
			var __direction:int = _isLeft ? -1 : 1;
			//根据站位的行数生成坐标
			for(var i:int=1; i<=ROW; i++)
			{
				drawPoint(i, __direction);
			}
			//drawPoint(ROW, __direction);
//			trace(ObjectUtil.toString(_points));
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
		
		public function getPointsJSON():String
		{
			throwJSONError(_points);
			return JSON.encode(_points);
		}
		
		public function getPointUsedJSON():String
		{
			throwJSONError(_pointUse);
			return JSON.encode(_pointUse);
		}
		
		private function throwJSONError($jsonSource:Object):void
		{
			if(!$jsonSource)
				throw new Error('没有站位数据！');
		}
		
		private function throwIndexError($length:int):void
		{
			if($length != 3)
				throw new Error('站位索引必须为3位数！');
		}
		
		//$direction，x计算方向，-1为从右到左，1为从左到右
		private function drawPoint($row:int, $direction:int=1):void
		{
			//垂直分隔的值根据行数来确定
			V_GAP = HEIGHT / $row;
			var __points:Array = [];
			var __color:Number = Math.random()*0xfffff;
			for(var i:int=0; i<COLUNM*$row; i++)
			{
				//列索引
				var __c:int = int(i%COLUNM);
				//行索引
				var __r:int = int(i/COLUNM);
				
				var __x:Number = _basePoint.x + $direction*(H_GAP/2 + H_GAP*__c);
				var __y:Number = _basePoint.y + getOffsetY($row, __r);
				
				var __point:Point = new Point(__x, __y);
				var __pointKey:String = $row + '' + __c + '' + __r; 
				_points[__pointKey] = __point;
				_pointUse[__pointKey] = false;
				
			}
		}
			
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