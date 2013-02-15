/*
 * ISO_3166.as
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
     * The ISO_3166 class enumerates the country codes as defined by 
     * the ISO 3166 standard.
     */
    public final class ISO_3166 
    {
        
        /**
         * @private
         */
        private static var _codes:Object;
        
        /**
         * A hashtable that associates the constants to their country code.
         * <p>For example, ISO_3166.FR returns the name of the country 
         * (France).<br/>
         * ISO_3166.codes[ISO_3166.FR] returns the country code (FR).</p>
         * 
         */
        public static function get codes():Object
        {
            if (_codes != null)
                return _codes;
            var codeConstants:XMLList = describeType(ISO_3166).constant;
            _codes = {};
            var codeConstant:XML;
            for each (codeConstant in codeConstants)
            {
                var name:String = codeConstant.@name;
                codes[ISO_3166[name]] = name;
            }
            return codes;
        }
        
        public static const AD:String = "Andorra"; 
        public static const AE:String = "United Arab Emirates"; 
        public static const AF:String = "Afghanistan"; 
        public static const AG:String = "Antigua and Barbuda"; 
        public static const AI:String = "Anguilla"; 
        public static const AL:String = "Albania"; 
        public static const AM:String = "Armenia"; 
        public static const AN:String = "Netherlands Antilles"; 
        public static const AO:String = "Angola"; 
        public static const AQ:String = "Antarctica"; 
        public static const AR:String = "Argentina"; 
        public static const AS:String = "Samoa (American)"; 
        public static const AT:String = "Austria"; 
        public static const AU:String = "Australia"; 
        public static const AW:String = "Aruba"; 
        public static const AX:String = "Aaland Islands"; 
        public static const AZ:String = "Azerbaijan"; 
        public static const BA:String = "Bosnia and Herzegovina"; 
        public static const BB:String = "Barbados"; 
        public static const BD:String = "Bangladesh"; 
        public static const BE:String = "Belgium"; 
        public static const BF:String = "Burkina Faso"; 
        public static const BG:String = "Bulgaria"; 
        public static const BH:String = "Bahrain"; 
        public static const BI:String = "Burundi"; 
        public static const BJ:String = "Benin"; 
        public static const BM:String = "Bermuda"; 
        public static const BN:String = "Brunei"; 
        public static const BO:String = "Bolivia"; 
        public static const BR:String = "Brazil"; 
        public static const BS:String = "Bahamas"; 
        public static const BT:String = "Bhutan"; 
        public static const BV:String = "Bouvet Island"; 
        public static const BW:String = "Botswana"; 
        public static const BY:String = "Belarus"; 
        public static const BZ:String = "Belize"; 
        public static const CA:String = "Canada"; 
        public static const CC:String = "Cocos (Keeling) Islands"; 
        public static const CD:String = "Congo (Dem. Rep.)"; 
        public static const CF:String = "Central African Republic"; 
        public static const CG:String = "Congo (Rep.)"; 
        public static const CH:String = "Switzerland"; 
        public static const CI:String = "Côte d'Ivoire"; 
        public static const CK:String = "Cook Islands"; 
        public static const CL:String = "Chile"; 
        public static const CM:String = "Cameroon"; 
        public static const CN:String = "China"; 
        public static const CO:String = "Colombia"; 
        public static const CR:String = "Costa Rica"; 
        public static const CU:String = "Cuba"; 
        public static const CV:String = "Cape Verde"; 
        public static const CX:String = "Christmas Island"; 
        public static const CY:String = "Cyprus"; 
        public static const CZ:String = "Czech Republic"; 
        public static const DE:String = "Germany"; 
        public static const DJ:String = "Djibouti"; 
        public static const DK:String = "Denmark"; 
        public static const DM:String = "Dominica"; 
        public static const DO:String = "Dominican Republic"; 
        public static const DZ:String = "Algeria"; 
        public static const EC:String = "Ecuador"; 
        public static const EE:String = "Estonia"; 
        public static const EG:String = "Egypt"; 
        public static const EH:String = "Western Sahara"; 
        public static const ER:String = "Eritrea"; 
        public static const ES:String = "Spain"; 
        public static const ET:String = "Ethiopia"; 
        public static const FI:String = "Finland"; 
        public static const FJ:String = "Fiji"; 
        public static const FK:String = "Falkland Islands"; 
        public static const FM:String = "Micronesia"; 
        public static const FO:String = "Faeroe Islands"; 
        public static const FR:String = "France"; 
        public static const GA:String = "Gabon"; 
        public static const GB:String = "Britain (United Kingdom)"; 
        public static const GD:String = "Grenada"; 
        public static const GE:String = "Georgia"; 
        public static const GF:String = "French Guiana"; 
        public static const GG:String = "Guernsey"; 
        public static const GH:String = "Ghana"; 
        public static const GI:String = "Gibraltar"; 
        public static const GL:String = "Greenland"; 
        public static const GM:String = "Gambia"; 
        public static const GN:String = "Guinea"; 
        public static const GP:String = "Guadeloupe"; 
        public static const GQ:String = "Equatorial Guinea"; 
        public static const GR:String = "Greece"; 
        public static const GS:String = "South Georgia and the South Sandwich Islands"; 
        public static const GT:String = "Guatemala"; 
        public static const GU:String = "Guam"; 
        public static const GW:String = "Guinea-Bissau"; 
        public static const GY:String = "Guyana"; 
        public static const HK:String = "Hong Kong"; 
        public static const HM:String = "Heard Island and McDonald Islands"; 
        public static const HN:String = "Honduras"; 
        public static const HR:String = "Croatia"; 
        public static const HT:String = "Haiti"; 
        public static const HU:String = "Hungary"; 
        public static const ID:String = "Indonesia"; 
        public static const IE:String = "Ireland"; 
        public static const IL:String = "Israel"; 
        public static const IM:String = "Isle of Man"; 
        public static const IN:String = "India"; 
        public static const IO:String = "British Indian Ocean Territory"; 
        public static const IQ:String = "Iraq"; 
        public static const IR:String = "Iran"; 
        public static const IS:String = "Iceland"; 
        public static const IT:String = "Italy"; 
        public static const JE:String = "Jersey"; 
        public static const JM:String = "Jamaica"; 
        public static const JO:String = "Jordan"; 
        public static const JP:String = "Japan"; 
        public static const KE:String = "Kenya"; 
        public static const KG:String = "Kyrgyzstan"; 
        public static const KH:String = "Cambodia"; 
        public static const KI:String = "Kiribati"; 
        public static const KM:String = "Comoros"; 
        public static const KN:String = "St Kitts and Nevis"; 
        public static const KP:String = "Korea (North)"; 
        public static const KR:String = "Korea (South)"; 
        public static const KW:String = "Kuwait"; 
        public static const KY:String = "Cayman Islands"; 
        public static const KZ:String = "Kazakhstan"; 
        public static const LA:String = "Laos"; 
        public static const LB:String = "Lebanon"; 
        public static const LC:String = "St Lucia"; 
        public static const LI:String = "Liechtenstein"; 
        public static const LK:String = "Sri Lanka"; 
        public static const LR:String = "Liberia"; 
        public static const LS:String = "Lesotho"; 
        public static const LT:String = "Lithuania"; 
        public static const LU:String = "Luxembourg"; 
        public static const LV:String = "Latvia"; 
        public static const LY:String = "Libya"; 
        public static const MA:String = "Morocco"; 
        public static const MC:String = "Monaco"; 
        public static const MD:String = "Moldova"; 
        public static const ME:String = "Montenegro"; 
        public static const MG:String = "Madagascar"; 
        public static const MH:String = "Marshall Islands"; 
        public static const MK:String = "Macedonia"; 
        public static const ML:String = "Mali"; 
        public static const MM:String = "Myanmar (Burma)"; 
        public static const MN:String = "Mongolia"; 
        public static const MO:String = "Macao"; 
        public static const MP:String = "Northern Mariana Islands"; 
        public static const MQ:String = "Martinique"; 
        public static const MR:String = "Mauritania"; 
        public static const MS:String = "Montserrat"; 
        public static const MT:String = "Malta"; 
        public static const MU:String = "Mauritius"; 
        public static const MV:String = "Maldives"; 
        public static const MW:String = "Malawi"; 
        public static const MX:String = "Mexico"; 
        public static const MY:String = "Malaysia"; 
        public static const MZ:String = "Mozambique"; 
        public static const NA:String = "Namibia"; 
        public static const NC:String = "New Caledonia"; 
        public static const NE:String = "Niger"; 
        public static const NF:String = "Norfolk Island"; 
        public static const NG:String = "Nigeria"; 
        public static const NI:String = "Nicaragua"; 
        public static const NL:String = "Netherlands"; 
        public static const NO:String = "Norway"; 
        public static const NP:String = "Nepal"; 
        public static const NR:String = "Nauru"; 
        public static const NU:String = "Niue"; 
        public static const NZ:String = "New Zealand"; 
        public static const OM:String = "Oman"; 
        public static const PA:String = "Panama"; 
        public static const PE:String = "Peru"; 
        public static const PF:String = "French Polynesia"; 
        public static const PG:String = "Papua New Guinea"; 
        public static const PH:String = "Philippines"; 
        public static const PK:String = "Pakistan"; 
        public static const PL:String = "Poland"; 
        public static const PM:String = "St Pierre and Miquelon"; 
        public static const PN:String = "Pitcairn"; 
        public static const PR:String = "Puerto Rico"; 
        public static const PS:String = "Palestine"; 
        public static const PT:String = "Portugal"; 
        public static const PW:String = "Palau"; 
        public static const PY:String = "Paraguay"; 
        public static const QA:String = "Qatar"; 
        public static const RE:String = "Reunion"; 
        public static const RO:String = "Romania"; 
        public static const RS:String = "Serbia"; 
        public static const RU:String = "Russia"; 
        public static const RW:String = "Rwanda"; 
        public static const SA:String = "Saudi Arabia"; 
        public static const SB:String = "Solomon Islands"; 
        public static const SC:String = "Seychelles"; 
        public static const SD:String = "Sudan"; 
        public static const SE:String = "Sweden"; 
        public static const SG:String = "Singapore"; 
        public static const SH:String = "St Helena"; 
        public static const SI:String = "Slovenia"; 
        public static const SJ:String = "Svalbard and Jan Mayen"; 
        public static const SK:String = "Slovakia"; 
        public static const SL:String = "Sierra Leone"; 
        public static const SM:String = "San Marino"; 
        public static const SN:String = "Senegal"; 
        public static const SO:String = "Somalia"; 
        public static const SR:String = "Suriname"; 
        public static const ST:String = "Sao Tome and Principe"; 
        public static const SV:String = "El Salvador"; 
        public static const SY:String = "Syria"; 
        public static const SZ:String = "Swaziland"; 
        public static const TC:String = "Turks and Caicos Islands"; 
        public static const TD:String = "Chad"; 
        public static const TF:String = "French Southern and Antarctic Lands"; 
        public static const TG:String = "Togo"; 
        public static const TH:String = "Thailand"; 
        public static const TJ:String = "Tajikistan"; 
        public static const TK:String = "Tokelau"; 
        public static const TL:String = "Timor-Leste"; 
        public static const TM:String = "Turkmenistan"; 
        public static const TN:String = "Tunisia"; 
        public static const TO:String = "Tonga"; 
        public static const TR:String = "Turkey"; 
        public static const TT:String = "Trinidad and Tobago"; 
        public static const TV:String = "Tuvalu"; 
        public static const TW:String = "Taiwan"; 
        public static const TZ:String = "Tanzania"; 
        public static const UA:String = "Ukraine"; 
        public static const UG:String = "Uganda"; 
        public static const UM:String = "US minor outlying islands"; 
        public static const US:String = "United States"; 
        public static const UY:String = "Uruguay"; 
        public static const UZ:String = "Uzbekistan"; 
        public static const VA:String = "Vatican City"; 
        public static const VC:String = "St Vincent and the Grenadines"; 
        public static const VE:String = "Venezuela"; 
        public static const VG:String = "Virgin Islands (UK)"; 
        public static const VI:String = "Virgin Islands (US)"; 
        public static const VN:String = "Vietnam"; 
        public static const VU:String = "Vanuatu"; 
        public static const WF:String = "Wallis and Futuna"; 
        public static const WS:String = "Samoa (Western)"; 
        public static const YE:String = "Yemen"; 
        public static const YT:String = "Mayotte"; 
        public static const ZA:String = "South Africa"; 
        public static const ZM:String = "Zambia"; 
        public static const ZW:String = "Zimbabwe";
        
    }
    
}
