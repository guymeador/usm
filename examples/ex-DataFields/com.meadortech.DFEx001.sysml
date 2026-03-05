// This file © 2025-2026 by Guy Meador is licensed under Apache-2.0
// # To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
// SPDX-License-Identifier: Apache-2.0

package 'com.meadortech.DFEx001' {
    doc 
        /* 
         * This package © 2025 by Guy Meador is licensed under Apache-2.0
         * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
         * SPDX-License-Identifier: Apache-2.0
         * 
         * See the comment Package_Overview for additional information
         */    
    comment Package_Overview
        /* 
         * This package provides a few simple examples based
         * upon the com.meadortech.DataFields package and
         * com.meadortech.DFScalarValues package base definitions.
         */

    alias DF for 'com.meadortech.DataFields';
    alias DFT for 'com.meadortech.DFScalarValues';
    alias be2colIdx for DFT::be2colIdx;


    item mb0 : DFT::Bit{
        doc /* Binds a Bit value to 1 */
        :>> value = 1;
    }

    item mb1 : DFT::Bit {
        doc /* Sets a Bit value to 1 */
        perform action {assign value := 1;}
    }

    item bm0 : DFT::BitMappedOctet {
        doc /* Binds a multiple Bit values in a bit-mapped octet */
        :>> b { :>> b0 {:>> value = 1;}
                :>> b7 {:>> value = 0;}
            }
    }

    item bm1 : DFT::BitMappedOctet {
        doc /* Sets multiple Bit values in a bit-mapped octet.
             * Note the use of Big Endian bit numbering being
             * used to reference the specific bit positions.
             */
        redefines b {
            perform action {
                assign b#(be2colIdx(0)).value := 1;
                assign b#(be2colIdx(7)).value := 1;
            }
        }        
    }

    item bm3 : DFT::BitMappedOctet {
        redefines subFields {
            perform action {
                assign subFields#(be2colIdx(0)).value := 1;
                assign subFields#(be2colIdx(7)).value := 1;
            }
        }
    }

    item def <BitSequence> BitSequencePField specializes DF::EPF {
        doc /* An experiment for having arbitrary-length bit
             * sequences with actions defined for setting, clearing,
             * and getting the value of specific bits. This
             * capability may find its way into a library package,
             * once it is mature. */
        attribute numbits : ScalarValues::Natural default 1;
        item b : DFT::Bit [numbits] ordered;
        :>> subFields = b;
        :>> fieldSize = numbits [SI::bit];

        action def setbit{
            inout bitSeq : BitSequence;
            in bitIdx;
            assign bitSeq#(bitIdx).value := 1;
        }
        action def clearbit{
            inout bitSeq : BitSequence;
            in bitIdx;
            assign bitSeq#(bitIdx).value := 0;
        }
        calc def getbit{
            in bitSeq : BitSequence;
            in bitIdx;
            bitSeq#(bitIdx).value
        }

    }

    item def <BitMappedSeqOctet> BitMappedBitSequenceOctet :> BitSequence {
        doc /* A less feature-rich experiment. */
        :>> numbits = 8;
        :>> b = (b0, b1, b2, b3, b4, b5, b6, b7);
        item b0 : DFT::Bit;
        item b1 : DFT::Bit;
        item b2 : DFT::Bit;
        item b3 : DFT::Bit;
        item b4 : DFT::Bit;
        item b5 : DFT::Bit;
        item b6 : DFT::Bit;
        item b7 : DFT::Bit;
    }

    item bmso1 : BitMappedSeqOctet {
        :>> b0 {:>> value = 1;}
        :>> b3 {:>> value = 1;}
    }


	item def Octets :> DF::EPF {
        :>> subFields = (numoctets, b);
		item numoctets : DFT::Word64;
		item b : DFT::Octet [numoctets.value] ordered;
	}

    item def Packet :> DF::EPF{
        :>> subFields = (dstAddr, srcAddr, data);
        item dstAddr : DFT::Word128;
        item srcAddr : DFT::Word128;
        item data    : Octets{
            :>> numoctets {:>> value default 128;}
        }
    }

    item myPacket : Packet {
        :>> dstAddr.value = 10;
        :>> srcAddr.value = 20;
        :>> data {
                :>> numoctets {:>> value = 2;}
                :>> b = (a, b);
            }
        item a : DFT::Octet {:>> value = 8;}
        item b : DFT::Octet {:>> value = 210;} 
    }
}