/**
 * Hex
 *
 * Utility class to convert Hex strings to ByteArray or String types.
 * Copyright (c) 2007 Henri Torgemane
 *
 * See LICENSE.txt for full license information.
 */
package static.chplayer.source.org.mangui.hls.utils {
    import flash.utils.ByteArray;

    public class Hex {
        /**
         * Generates byte-array from given hexadecimal string
         *
         * Supports straight and colon-laced hex (that means 23:03:0e:f0, but *NOT* 23:3:e:f0)
         * The first nibble (hex digit) may be omitted.
         * Any whitespace characters are ignored.
         */
        public static function toArray(hex : String) : ByteArray {
            hex = hex.replace(/^0x|\s|:/gm, '');
            var a : ByteArray = new ByteArray;
            if ((hex.length & 1) == 1) hex = "0" + hex;
            for (var i : uint = 0; i < hex.length; i += 2) {
                a[i / 2] = parseInt(hex.substr(i, 2), 16);
            }
            return a;
        }

        /**
         * Generates lowercase hexadecimal string from given byte-array
         */
        public static function fromArray(array : ByteArray, colons : Boolean = false) : String {
            var s : String = "";
            for (var i : uint = 0; i < array.length; i++) {
                s += ("0" + array[i].toString(16)).substr(-2, 2);
                if (colons) {
                    if (i < array.length - 1) s += ":";
                }
            }
            return s;
        }
    }
}
