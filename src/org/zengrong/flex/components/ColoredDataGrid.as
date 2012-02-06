/**
 * 继承DataGrid,为其添加行背景色功能
 */
package org.zengrong.flex.controls
{
	import mx.controls.DataGrid;
	import flash.display.Sprite;
	import mx.collections.ArrayCollection;

	public class ColoredDataGrid extends DataGrid
	{
		[Bindable]
		public var rowColorFunction:Function;
		
		public function ColoredDataGrid()
		{
			super();
		}
		
		override protected function drawRowBackground($s:Sprite, $rowIndex:int, $y:Number, $height:Number, $color:uint, $dataIndex:int):void
		{
			if( rowColorFunction != null && dataProvider != null) {
				var _dp:ArrayCollection = dataProvider as ArrayCollection;
				var _item:Object;
				if( $dataIndex < _dp.length ) 
				{
					_item = _dp.getItemAt($dataIndex);
					$color = rowColorFunction( _item, $rowIndex, $dataIndex, $color );
				}				
			}
			super.drawRowBackground($s, $rowIndex, $y, $height, $color, $dataIndex);
		}	
	}
}