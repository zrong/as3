/*
 * ISO_639_1.as
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
    
    import flash.utils.describeType;
    
    /**
     * The ISO_639_1 class enumerates the country codes as defined by 
     * the ISO 639-1 standard.
     */
    public final class ISO_639_1 
    {
        
        /**
         * @private
         */
        private static var _codes:Object;
        
        /**
         * A hashtable that associates the constants to their language code.
         * <p>For example, ISO_639_1.FR returns the name of the language
         * (French).<br/>
         * ISO_639_1.codes[ISO_639_1.FR] returns the language code (fr).</p>
         * 
         */
        public static function get codes():Object
        {
            if (_codes != null)
                return _codes;
            var codeConstants:XMLList = describeType(ISO_639_1).constant;
            _codes = {};
            var codeConstant:XML;
            for each (codeConstant in codeConstants)
            {
                var name:String = codeConstant.@name;
                codes[ISO_639_1[name]] = name.toLowerCase();
            }
            return codes;
        }
        
        public static const AA:String = "Afar. ";
        public static const AB:String = "Abkhazian";
        public static const AD:String = "Adangme";
        public static const AE:String = "Avestan";
        public static const AF:String = "Afrikaans";
        public static const AK:String = "Akan";
        public static const AM:String = "Amharic";
        public static const AN:String = "Aragonese";
        public static const AR:String = "Arabic";
        public static const AS:String = "Assamese";
        public static const AV:String = "Avaric";
        public static const AY:String = "Aymara";
        public static const AZ:String = "Azerbaijani";
        public static const BA:String = "Bashkir";
        public static const BE:String = "Byelorussian; Belarusian";
        public static const BG:String = "Bulgarian";
        public static const BH:String = "Bihari";
        public static const BI:String = "Bislama";
        public static const BM:String = "Bambara";
        public static const BN:String = "Bengali; Bangla";
        public static const BO:String = "Tibetan";
        public static const BR:String = "Breton";
        public static const BS:String = "Bosnian";
        public static const CA:String = "Catalan";
        public static const CE:String = "Chechen";
        public static const CH:String = "Chamorro";
        public static const CO:String = "Corsican";
        public static const CR:String = "Cree";
        public static const CS:String = "Czech";
        public static const CU:String = "Church Slavic";
        public static const CV:String = "Chuvash";
        public static const CY:String = "Welsh";
        public static const DA:String = "Danish";
        public static const DE:String = "German";
        public static const DV:String = "Divehi; Maldivian";
        public static const DZ:String = "Dzongkha; Bhutani";
        public static const EE:String = "Éwé";
        public static const EL:String = "Greek";
        public static const EN:String = "English";
        public static const EO:String = "Esperanto";
        public static const ES:String = "Spanish";
        public static const ET:String = "Estonian";
        public static const EU:String = "Basque";
        public static const FA:String = "Persian";
        public static const FF:String = "Fulah";
        public static const FI:String = "Finnish";
        public static const FJ:String = "Fijian; Fiji";
        public static const FO:String = "Faroese";
        public static const FR:String = "French";
        public static const FY:String = "Western Frisian";
        public static const GA:String = "Irish";
        public static const GD:String = "Scots; Gaelic";
        public static const GL:String = "Galician";
        public static const GN:String = "Guarani";
        public static const GU:String = "Gujarati";
        public static const GV:String = "Manx";
        public static const HA:String = "Hausa";
        public static const HE:String = "Hebrew (formerly iw)";
        public static const HI:String = "Hindi";
        public static const HO:String = "Hiri Motu";
        public static const HR:String = "Croatian";
        public static const HT:String = "Haitian; Haitian Creole";
        public static const HU:String = "Hungarian";
        public static const HY:String = "Armenian";
        public static const HZ:String = "Herero";
        public static const IA:String = "Interlingua";
        public static const ID:String = "Indonesian (formerly in)";
        public static const IE:String = "Interlingue";
        public static const IG:String = "Igbo";
        public static const IK:String = "Inupiak; Inupiaq";
        public static const IO:String = "Ido";
        public static const IS:String = "Icelandic";
        public static const IT:String = "Italian";
        public static const IU:String = "Inuktitut";
        public static const JA:String = "Japanese";
        public static const JV:String = "Javanese";
        public static const KA:String = "Georgian";
        public static const KG:String = "Kongo";
        public static const KI:String = "Kikuyu; Gikuyu";
        public static const KJ:String = "Kuanyama; Kwanyama";
        public static const KK:String = "Kazakh";
        public static const KL:String = "Kalaallisut; Greenlandic";
        public static const KM:String = "Khmer; Cambodian";
        public static const KN:String = "Kannada";
        public static const KO:String = "Korean";
        public static const KS:String = "Kashmiri";
        public static const KU:String = "Kurdish";
        public static const KV:String = "Komi";
        public static const KW:String = "Cornish";
        public static const KY:String = "Kirghiz";
        public static const LA:String = "Latin";
        public static const LB:String = "Letzeburgesch; Luxembourgish";
        public static const LG:String = "Ganda";
        public static const LI:String = "Limburgish; Limburger; Limburgan";
        public static const LN:String = "Lingala";
        public static const LO:String = "Lao; Laotian";
        public static const LT:String = "Lithuanian";
        public static const LU:String = "Luba-Katanga";
        public static const LV:String = "Latvian; Lettish";
        public static const MG:String = "Malagasy";
        public static const MH:String = "Marshallese";
        public static const MI:String = "Maori";
        public static const MK:String = "Macedonian";
        public static const ML:String = "Malayalam";
        public static const MN:String = "Mongolian";
        public static const MO:String = "Moldavian";
        public static const MR:String = "Marathi";
        public static const MS:String = "Malay";
        public static const MT:String = "Maltese";
        public static const MY:String = "Burmese";
        public static const NA:String = "Nauru";
        public static const NB:String = "Norwegian Bokmål";
        public static const ND:String = "Ndebele; North";
        public static const NE:String = "Nepali";
        public static const NG:String = "Ndonga";
        public static const NL:String = "Dutch";
        public static const NN:String = "Norwegian Nynorsk";
        public static const NO:String = "Norwegian";
        public static const NR:String = "Ndebele; South";
        public static const NV:String = "Navajo; Navaho";
        public static const NY:String = "Chichewa; Nyanja";
        public static const OC:String = "Occitan; Provençal";
        public static const OM:String = "(Afan) Oromo";
        public static const OR:String = "Oriya";
        public static const OS:String = "Ossetian; Ossetic";
        public static const PA:String = "Panjabi; Punjabi";
        public static const PI:String = "Pali";
        public static const PL:String = "Polish";
        public static const PS:String = "Pashto; Pushto";
        public static const PT:String = "Portuguese";
        public static const QU:String = "Quechua";
        public static const RM:String = "Rhaeto-Romance";
        public static const RN:String = "Rundi; Kirundi";
        public static const RO:String = "Romanian";
        public static const RU:String = "Russian";
        public static const RW:String = "Kinyarwanda";
        public static const SA:String = "Sanskrit";
        public static const SC:String = "Sardinian";
        public static const SD:String = "Sindhi";
        public static const SE:String = "Northern Sami";
        public static const SG:String = "Sango; Sangro";
        public static const SI:String = "Sinhala; Sinhalese";
        public static const SK:String = "Slovak";
        public static const SL:String = "Slovenian";
        public static const SM:String = "Samoan";
        public static const SN:String = "Shona";
        public static const SO:String = "Somali";
        public static const SQ:String = "Albanian";
        public static const SR:String = "Serbian";
        public static const SS:String = "Swati; Siswati";
        public static const ST:String = "Sesotho; Sotho; Southern";
        public static const SU:String = "Sundanese";
        public static const SV:String = "Swedish";
        public static const SW:String = "Swahili";
        public static const TA:String = "Tamil";
        public static const TE:String = "Telugu";
        public static const TG:String = "Tajik";
        public static const TH:String = "Thai";
        public static const TI:String = "Tigrinya";
        public static const TK:String = "Turkmen";
        public static const TL:String = "Tagalog";
        public static const TN:String = "Tswana; Setswana";
        public static const TO:String = "Tonga";
        public static const TR:String = "Turkish";
        public static const TS:String = "Tsonga";
        public static const TT:String = "Tatar";
        public static const TW:String = "Twi";
        public static const TY:String = "Tahitian";
        public static const UG:String = "Uighur";
        public static const UK:String = "Ukrainian";
        public static const UR:String = "Urdu";
        public static const UZ:String = "Uzbek";
        public static const VI:String = "Vietnamese";
        public static const VO:String = "Volapük; Volapuk";
        public static const WA:String = "Walloon";
        public static const WO:String = "Wolof";
        public static const XH:String = "Xhosa";
        public static const YI:String = "Yiddish (formerly ji)";
        public static const YO:String = "Yoruba";
        public static const ZA:String = "Zhuang";
        public static const ZH:String = "Chinese";
        public static const ZU:String = "Zulu";

    }
        
}
