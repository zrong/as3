package org.zengrong.air.utils
{
import flash.desktop.NativeApplication;

public function getDesc($name:String):String
{
	var __desc:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var __ns:Namespace = __desc.namespace();
	return __desc.__ns::[$name];
}
}