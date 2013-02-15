/*
 * _Locale.as
 * This file is part of Actionscript GNU Gettext 
 *
 * Copyright (C) 2010 - Vincent Petithory
 *
 * Actionscript GNU Gettext is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * Actionscript GNU Gettext is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
package gnu.as3.gettext 
{

    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import flash.utils.Dictionary;
    import flash.system.Capabilities;
    
    /**
     * Dispatched when the setlocale() method is called and 
     * results in changing the current locale.
     */
    [Event(name="change", type="flash.events.Event")]
    
    /**
     * A _Locale manages the locale in an application. Usually, you use the 
     * unique Locale object, instead of creating your own.
     */
    public final class _Locale extends EventDispatcher 
    {
        
        /**
         * @private
         */
        private var pwd_inc:uint = 0;
        
        /**
         * The standard messages.
         */
        public const LC_MESSAGES:uint = 1 << pwd_inc++;
        
        /**
         * @private
         * Not used yet.
         */
        public const LC_TIME:uint = 1 << pwd_inc++;
        
        /**
         * @private
         * Not used yet.
         */
        public const LC_MONETARY:uint = 1 << pwd_inc++;
        
        /**
         * @private
         * Not used yet.
         */
        public const LC_NUMERIC:uint = 1 << pwd_inc++;
        
        /**
         * @private
         * Not used yet.
         */
        public const LC_COLLATE:uint = 1 << pwd_inc++;
        
        /**
         * @private
         * LC_CTYPE is essentially used to determine locales in some standard
         * C functions. There is no such things to localize in AS3, but it 
         * may be used in your own functions if you use gettext to 
         * localize your library.
         * Not used yet.
         */
        public const LC_CTYPE:uint = 1 << pwd_inc++;
        
        
        
        /**
         * The directory where messages are stored. This directory exists in 
         * each {locale_dir}/xx_XX locale directory.
         */
        public const LC_MESSAGES_DIR:String = "LC_MESSAGES";
        
        /**
         * @private
         * The number of categories.
         */
        private const NUM_LC:uint = pwd_inc;
        
        /**
         * @private
         * The dictionary of the locales associated to the categories.
         */
        private var _locales:Dictionary = new Dictionary(false);
        
        /**
         * The priority list of locales, colon-separeted.
         * Unlike the system LANGUAGE variable used by the legacy Gettext
         * library, you have to set the complete locale (ll_CC), not just the 
         * locale itself (ll).
         */
        public var LANGUAGE:String = "";
        
        /**
         * The user default language. Use the mklocale() function to set it.
         */
        public var LC_ALL:String;
        
        /**
         * @private
         */
        private const __FP_ISO639_TO_LOCALE__:Object = { 
            'cs'    : 'cs_CZ',
            'da'    : 'da_DK',
            'nl'    : 'nl_NL',
            'en'    : 'en_US',
            'fi'    : 'fi_FI',
            'fr'    : 'fr_FR',
            'de'    : 'de_DE',
            'hu'    : 'hu_HU',
            'it'    : 'it_IT',
            'ja'    : 'ja_JP',
            'ko'    : 'ko_KR',
            'no'    : 'no_NO',
            'xu'    : 'en_US',
            'pl'    : 'pl_PL',
            'pt'    : 'pt_PT',
            'ru'    : 'ru_RU',
            'zh-CN' : 'zh_CN',
            'es'    : 'es_ES',
            'sv'    : 'sv_SE',
            'zh-TW' : 'zh_TW',
            'tr'    : 'tr_TR' 
        };
        
        /**
         * The native locale of the system, which defaults to the language 
         * Flash Player determines (see the table below).
         * 
         * <p>As Flash Player only determines a language code, not a full locale, 
         * a locale is made out of that language code. When Flash Player 
         * encounters an unknown locale, then en_US is used by default.
         * The following table 
         * shows the mapping between flash player language codes and locales 
         * (an ISO 639-1 code, followed by a _ character, followed by an 
         * ISO 3166 code) :</p>
         * <table class="innertable">
         *     <tr><th>Flash Player language code</th><th>Locale</th></tr>
         *     <tr><td>cs</td><td>cs_CZ</td></tr>
         *     <tr><td>da</td><td>da_DK</td></tr>
         *     <tr><td>nl</td><td>nl_NL</td></tr>
         *     <tr><td>en</td><td>en_US</td></tr>
         *     <tr><td>fi</td><td>fi_FI</td></tr>
         *     <tr><td>fr</td><td>fr_FR</td></tr>
         *     <tr><td>de</td><td>de_DE</td></tr>
         *     <tr><td>hu</td><td>hu_HU</td></tr>
         *     <tr><td>it</td><td>it_IT</td></tr>
         *     <tr><td>ja</td><td>ja_JP</td></tr>
         *     <tr><td>ko</td><td>ko_KR</td></tr>
         *     <tr><td>no</td><td>no_NO</td></tr>
         *     <tr><td>xu</td><td>en_US</td></tr>
         *     <tr><td>pl</td><td>pl_PL</td></tr>
         *     <tr><td>pt</td><td>pt_PT</td></tr>
         *     <tr><td>ru</td><td>ru_RU</td></tr>
         *     <tr><td>zh-CN</td><td>zh_CN</td></tr>
         *     <tr><td>es</td><td>es_ES</td></tr>
         *     <tr><td>sv</td><td>sv_SE</td></tr>
         *     <tr><td>zh-TW</td><td>zh_TW</td></tr>
         *     <tr><td>tr</td><td>tr_TR</td></tr>
         * </table>
         * 
         */
        public const LANG:String = __FP_ISO639_TO_LOCALE__[Capabilities.language];
        
        /**
         * The setlocale() method encapsulates all the logic to set and 
         * retrieve the current locale. 
         * 
         * <p>The default locale for a given category is determined in the 
         * following order :
         * <ul>
         * <li>the value assigned to the category, if any.</li>
         * <li>the value of the global LANGUAGE variable, if set.</li>
         * <li>the value of the LANG const, which defaults to the language 
         * Flash Player determines (see the LANG constant for more 
         * informations).</li>
         * </ul>
         * </p>
         * 
         * @param category the category to set/retrieve information.
         * @param locale the locale to set. If not null, the specified locale 
         * will be set for the specified category. If null, the method will 
         * return the current locale for the specified category. 
         * Use the mklocale() function to create a standard locale.
         * 
         * @see mklocale()
         */
        public function setlocale(category:uint, locale:String = null):String
        {
            var pw:int = 0;
            var lc:uint;
            if (locale == null)
            {
                if (this.LANGUAGE != null && this.LANGUAGE != "")
                {
                    // return the first locale of the list
                    var i:int = this.LANGUAGE.indexOf(":");
                    if (i == -1)
                        return this.LANGUAGE;
                    else
                        return this.LANGUAGE.substring(0,i);
                }
                if (this.LC_ALL != null && this.LC_ALL != "")
                {
                    return this.LC_ALL;
                }
                var numCats:uint = 0;
                var cat:uint = 0;
                for (pw = 0; pw < NUM_LC; pw++)
                {
                    lc = 1 << pw;
                    if (category == lc)
                    {
                        cat = lc;
                        numCats++;
                    }
                }
                if (numCats == 1 && _locales[cat] != undefined)
                    return _locales[cat];
                else
                    return LANG;
            }
            if (locale == "")
            {
                locale = setlocale(category, null);
            }
            for (pw = 0; pw < NUM_LC; pw++)
            {
                lc = 1 << pw;
                var isLocaleChanged:Boolean = false;
                if ((category & lc) == lc)
                {
                    var oldLocale:String = _locales[lc];
                    _locales[lc] = locale;
                    if (oldLocale != locale)
                        isLocaleChanged = true;
                }
                // dispatch locale change event here
                if (isLocaleChanged)
                    this.dispatchEvent(new Event(Event.CHANGE));
            }
            return locale;
        }
        
        private static const FILTER_LOCALE_LIST:Function = function (item:String,i:int,a:Array):Boolean
        {
            return item.length > 0;
        }
        
        public function getPriorityList():Array
        {
            return this.LANGUAGE.split(":").filter(FILTER_LOCALE_LIST);
        }
        
    }
    
}
