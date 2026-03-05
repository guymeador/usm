// This file © 2025-2026 by Guy Meador is licensed under Apache-2.0
// # To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
// SPDX-License-Identifier: Apache-2.0

library package 'com.meadortech.DFScalarValues' {
    doc 
        /* 
         * This package © 2025-2026 by Guy Meador is licensed under Apache-2.0
         * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
         * SPDX-License-Identifier: Apache-2.0
         * 
         * See the comment Package_Overview for additional information
         */    

    comment Package_Overview
        /* 
         * This package provides ScalarValues representations based
         * upon the com.meadortech.DataFields package base definitions.
         */

    comment Status 
        /*
         * Full coverage of ScalarValues types as DataFields is as yet
         * incomplete.
         */

    comment 'About Big Endian Assumption'
        /* The current assumption for this package is that bit ordering
         * is Big Endian. */

    public import SI::**; 

    alias DF for 'com.meadortech.DataFields';

    item def Bit :> DF::EPF {
        doc 
            /* A fundamental definition of a classical bit as a packed field
             * constrained to a value of = 0..1 
             */

        redefines value : ScalarValues::Natural default 0;
        assert constraint rangeCheck {value == 0 or value == 1}
        redefines fieldSize = 1 [bit];
        redefines subFields [0];
    }
    item def <Octet> OctetPField specializes DF::EPF{
        redefines value : ScalarValues::Natural;
        assert constraint checkRange {0 <= value and value <= (2^8 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 1 [byte];
    }
    item def <OctetSigned> OctetSignedPField specializes DF::EPF{
        redefines value : ScalarValues::Integer;
        assert constraint checkRange {-(2^7) <= value and value <= 2^7-1}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 1 [byte];
    }
    item def <BitMappedOctet> BitMappedOctetPField specializes Octet{
        redefines subFields = b;
        item b : Bit[8] ordered = (b0, b1, b2, b3, b4, b5, b6, b7);
        item b0 : Bit;
        item b1 : Bit;
        item b2 : Bit;
        item b3 : Bit;
        item b4 : Bit;
        item b5 : Bit;
        item b6 : Bit;
        item b7 : Bit;
    }
    item def <Word16> Word16PField specializes DF::EPF{
        redefines value : ScalarValues::Natural;
        assert constraint checkRange {0 <= value and value <= (2^16 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 2 [byte];
    }
    item def <BitMappedWord16> BitMappedWord16PField specializes Word16 {
        redefines subFields = b;
        item b : Bit[16] ordered =
            (b0, b1, b2,  b3,  b4,  b5,  b6,  b7,
             b8, b9, b10, b11, b12, b13, b14, b15);
        item b0 : Bit;
        item b1 : Bit;
        item b2 : Bit;
        item b3 : Bit;
        item b4 : Bit;
        item b5 : Bit;
        item b6 : Bit;
        item b7 : Bit;
        item b8 : Bit;
        item b9 : Bit;
        item b10 : Bit;
        item b11 : Bit;
        item b12 : Bit;
        item b13 : Bit;
        item b14 : Bit;
        item b15 : Bit;
    }
    item def <Integer16> Integer16PField specializes DF::EPF{
        redefines value : ScalarValues::Integer;
        assert constraint checkRange {-(2^15) <= value and value <= 2^15-1}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 2 [byte];
    }

    item def <Word32> Word32PField specializes DF::EPF{
        redefines value : ScalarValues::Natural;
        assert constraint checkRange {0 <= value and value <= (2^32 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 4 [byte];
    }
    item def <BitMappedWord32> BitMappedWord32PField specializes Word32 {
        redefines subFields = b;
        item b : Bit[16] ordered =
            (b0,  b1,  b2,  b3,  b4,  b5,  b6,  b7,
             b8,  b9,  b10, b11, b12, b13, b14, b15,
             b16, b17, b18, b19, b20, b21, b22, b23,
             b24, b25, b26, b27, b28, b29, b30, b31);
        item b0 : Bit;
        item b1 : Bit;
        item b2 : Bit;
        item b3 : Bit;
        item b4 : Bit;
        item b5 : Bit;
        item b6 : Bit;
        item b7 : Bit;
        item b8 : Bit;
        item b9 : Bit;
        item b10 : Bit;
        item b11 : Bit;
        item b12 : Bit;
        item b13 : Bit;
        item b14 : Bit;
        item b15 : Bit;
        item b16 : Bit;
        item b17 : Bit;
        item b18 : Bit;
        item b19 : Bit;
        item b20 : Bit;
        item b21 : Bit;
        item b22 : Bit;
        item b23 : Bit;
        item b24 : Bit;
        item b25 : Bit;
        item b26 : Bit;
        item b27 : Bit;
        item b28 : Bit;
        item b29 : Bit;
        item b30 : Bit;
        item b31 : Bit;
    }
    item def <Integer32> Integer32PField specializes DF::EPF{
        redefines value : ScalarValues::Integer;
        assert constraint checkRange {-(2^31) <= value and value <= 2^31-1}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 4 [byte];
    }

    item def <Word64> Word64PField specializes DF::EPF{
        redefines value : ScalarValues::Natural;
        assert constraint checkRange {0 <= value and value <= (2^64 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 8 [byte];
    }
    item def <Integer64> Integer64PField specializes DF::EPF{
        redefines value : ScalarValues::Integer;
        assert constraint checkRange {-(2^63) <= value and value <= 2^63-1}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 8 [byte];
    }
    item def <Word128> Word128PField specializes DF::EPF{
        redefines value : ScalarValues::Natural;
        assert constraint checkRange {0 <= value and value <= (2^128 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 128 [bit];
    }
    item def <Integer128> Integer128PField specializes DF::EPF{
        redefines value : ScalarValues::Integer;
        assert constraint checkRange {-(2^127) <= value and value <= 2^127-1}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the allowed value range
                 */
        redefines fieldSize = 128 [bit];
    }

    calc def <be2colIdx> fnBigEndianIndexToCollectionIndex {
        doc
            /* Converts the zero-based Big Endian bit number into 
                * the 1-based SysML collection index number 
                */
        /* SysML collection indexing is 1..* while Big Endian
            * bit numbering is 0..*
            */

        in bebitnum;
        (bebitnum + 1)
    }


}