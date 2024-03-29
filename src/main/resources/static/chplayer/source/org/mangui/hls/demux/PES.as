/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
 package static.chplayer.source.org.mangui.hls.demux {
    import flash.utils.ByteArray;

    /** Representation of a Packetized Elementary Stream. **/
    public class PES {
        /** Is it AAC audio or AVC video. **/
        public var audio : Boolean;
        /** The PES data (including headers). **/
        public var data : ByteArray;
        /** Start of the payload. **/
        public var payload : uint;
        /** Timestamp from the PTS header. **/
        public var pts : Number;
        /** Timestamp from the DTS header. **/
        public var dts : Number;
        /** PES packet len **/
        public var len : int;
        /** PES packet len **/
        public var payload_len : int;

        /** Save the first chunk of PES data. **/
        public function PES(dat : ByteArray, aud : Boolean) {
            data = dat;
            audio = aud;
            parse();
        };

        /** When all data is appended, parse the PES headers. **/
        private function parse() : void {
            data.position = 0;
            // Start code prefix and packet ID.
            var prefix : uint = data.readUnsignedInt();
            /*Audio streams (0x1C0-0x1DF)
            Video streams (0x1E0-0x1EF)
            0x1BD is special case, could be audio or video (ffmpeg\libavformat\mpeg.c)
             */
            if ((audio && (prefix > 0x1df || prefix < 0x1c0 && prefix != 0x1bd)) || (!audio && prefix != 0x1e0 && prefix != 0x1ea && prefix != 0x1bd)) {
                throw new Error("PES start code not found or not AAC/AVC: " + prefix);
            }
            // read len
            len = data.readUnsignedShort();
            // Ignore marker bits.
            data.position += 1;
            // Check for PTS
            var flags : uint = (data.readUnsignedByte() & 192) >> 6;
            // Check PES header length
            var length : uint = data.readUnsignedByte();

            if (flags == 2 || flags == 3) {
                // Grab the timestamp from PTS data (spread out over 5 bytes):
                // XXXX---X -------- -------X -------- -------X

                var _pts : Number = Number((data.readUnsignedByte() & 0x0e)) * Number(1 << 29) + Number((data.readUnsignedShort() >> 1) << 15) + Number((data.readUnsignedShort() >> 1));
                // check if greater than 2^32 -1
                if (_pts > 4294967295) {
                    // decrement 2^33
                    _pts -= 8589934592;
                }
                length -= 5;
                var _dts : Number = _pts;
                if (flags == 3) {
                    // Grab the DTS (like PTS)
                    _dts = Number((data.readUnsignedByte() & 0x0e)) * Number(1 << 29) + Number((data.readUnsignedShort() >> 1) << 15) + Number((data.readUnsignedShort() >> 1));
                    // check if greater than 2^32 -1
                    if (_dts > 4294967295) {
                        // decrement 2^33
                        _dts -= 8589934592;
                    }
                    length -= 5;
                }
                pts = Math.round(_pts / 90);
                dts = Math.round(_dts / 90);
                // CONFIG::LOGGING {
                // Log.info("pts/dts: " + pts + "/"+ dts);
                // }
            }
            // Skip other header data and parse payload.
            data.position += length;
            payload = data.position;
            if(len) {
                payload_len = len - data.position + 6;
            } else {
                payload_len = 0;
            }
        };
    }
}