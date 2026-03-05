/* 
 * This file © 2025 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  

package 'com.meadortech.DFExperimental'{
    doc 
    /* 
        * This package © 2025 by Guy Meador is licensed under Apache-2.0
        * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
        * SPDX-License-Identifier: Apache-2.0
        * 
        * See the comment Package_Overview for additional information
        */    

    // Numeric sub-types particularly useful but not defined in standard packages

    private import 'com.meadortech.DataFields';

    attribute def Bit specializes Natural { 
    doc 
        /* A fundamental definition of the range of a classical bit = 0..1 */
    
    assert constraint checkBitRange {(that == 0) or (that == 1)}
        comment about checkBitRange
            /* The checkBitRange constraint ensures that any usage of Bit conforms
             * to the value range 0..1 . The constraint uses 'that' which is a feature
             * defined in Base.kerml 
             */
    }


    attribute def Integer8 :> Integer {
        assert constraint checkRange {-(2^8) <= that and that <= 2^8-1}
    }
    attribute def Integer16 :> Integer {
        assert constraint checkRange {-(2^16) <= that and that <= 2^16-1}
    }
    attribute def Integer32 :> Integer {
        assert constraint checkRange {-(2^32) <= that and that <= 2^32-1}
    }
    attribute def Integer64 :> Integer {
        assert constraint checkRange {-(2^64) <= that and that <= 2^64-1}
    }
    attribute def Integer128 :> Integer {
        assert constraint checkRange {-(2^128) <= that and that <= 2^128-1}
    }
    attribute def Integer256 :> Integer {
        assert constraint checkRange {-(2^256) <= that and that <= 2^256-1}
    }
    attribute def Integer512 :> Integer {
        assert constraint checkRange {-(2^512) <= that and that <= 2^512-1}
    }

    
    attribute def Natural5 :> Natural {
        assert constraint checkRange {0 <= that and that <= 2^5-1}
    }
    attribute def Natural8 specializes Natural{
        assert constraint checkRange {0 <= that and that <= (2^8 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the value range 0..255 . The constraint uses 'that' which is a feature
                 * defined in Base.kerml 
                 */
    }
    attribute def Natural16 specializes Natural{
        assert constraint checkRange {0 <= that and that <= (2^16 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the indicated value range. The constraint uses 'that' which is a feature
                 * defined in Base.kerml 
                 */
    }
    attribute def Natural32 specializes Natural{
        assert constraint checkRange {0 <= that and that <= (2^32 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the indicated value range. The constraint uses 'that' which is a feature
                 * defined in Base.kerml 
                 */
    }
    attribute def Natural64 specializes Natural{
        assert constraint checkRange {0 <= that and that <= (2^64 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the indicated value range. The constraint uses 'that' which is a feature
                 * defined in Base.kerml 
                 */
    }
    attribute def Natural128 specializes Natural{
        assert constraint checkRange {0 <= that and that <= (2^128 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the indicated value range. The constraint uses 'that' which is a feature
                 * defined in Base.kerml 
                 */
    }
    attribute def Natural256 specializes Natural{
        assert constraint checkRange {0 <= that and that <= (2^256 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the indicated value range. The constraint uses 'that' which is a feature
                 * defined in Base.kerml 
                 */
    }
    attribute def Natural512 specializes Natural{
        assert constraint checkRange {0 <= that and that <= (2^512 - 1)}
            comment about checkRange
                /* The checkRange constraint ensures that any usage of this type conforms
                 * to the indicated value range. The constraint uses 'that' which is a feature
                 * defined in Base.kerml 
                 */
    }



	// TODO Finish making unpacked field versions of the above numeric subtypes
    
    
    item def BinaryDigitField :> Field {
    	doc /* A single binary digit in unpacked field form */
        redefines value : Bit default 0;
        redefines minSizePacked = 1 [bit];
        redefines subFields [0];
    }
	item def Integer8Field specializes Field{
		redefines value : Integer8 default 0;
	}
	item def Integer16Field specializes Field{
		redefines value : Integer16 default 0;
	}
	item def Integer32Field specializes Field{
		redefines value : Integer32 default 0;
	}
	item def Integer64Field specializes Field{
		redefines value : Integer64 default 0;
	}
	item def Integer128Field specializes Field{
		redefines value : Integer128 default 0;
	}
	item def Natural5Field specializes Field{
		redefines value : Natural5 default 0;
	}
	item def Natural8Field specializes Field{
		redefines value : Natural8 default 0;
	}
	item def Natural16Field specializes Field{
		redefines value : Natural16 default 0;
	}
	item def Natural32Field specializes Field{
		redefines value : Natural32 default 0;
	}
	item def Natural64Field specializes Field{
		redefines value : Natural64 default 0;
	}
	item def Natural128Field specializes Field{
		redefines value : Natural128 default 0;
	}
	

    
    // ExactlyPackedFields for the numeric types
    // TODO Make Integer EPF item defs
    
    item def <BinaryDigit> BinaryDigitPackedField specializes BinaryDigitField, EPF{
    	doc /* A single binary digit in a 1-bit packed field */
    	attribute minSizePacked redefines BinaryDigitField::minSizePacked redefines EPF::minSizePacked;
        attribute fieldSize redefines BinaryDigitField::fieldSize redefines EPF::fieldSize = 1 [bit];
    }

    // TODO Make elem's encOffset be bound to correct value for each of thes "plural" fields
	item def BinaryDigits specializes EPF, CompositeField{
        attribute num : Natural default 1;
        attribute fieldSize redefines EPF::fieldSize redefines CompositeField::fieldSize = num [bit];
        item subFields redefines EPF::subFields redefines CompositeField::subFields;
        subfields = (elem);
        item elem : BinaryDigit [num] ordered;
    }
	item def <Word5> Word5PField :> Natural5Field, ExactlyPackedField{
		attribute fieldSize redefines Natural5Field::fieldSize redefines EPF::fieldSize = 5 [bit];
	}
    item def <Octet> OctetPField specializes Natural8Field, ExactlyPackedField{
	    attribute fieldSize redefines Natural8Field::fieldSize redefines EPF::fieldSize = 1 [byte];
    }
	item def Octets specializes EPF, CompositeField{
        attribute num : Natural default 1;
        attribute fieldSize redefines CompositeField::fieldSize redefines EPF::fieldSize = num [byte];
        item subFields redefines CompositeField::subFields redefines EPF::subFields = elem;
        item elem : Octet [num] ordered;
    }
    item def <Word16> Word16PField specializes Natural16Field, ExactlyPackedField{
        redefines Natural16Field::fieldSize redefines EPF::fieldSize = 2 [byte];
    }
	item def Words16 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines EPF::fieldSize redefines CompositeField::fieldSize = num * 16 [byte];
        redefines EPF::subFields redefines CompositeField::subFields = elem;
        item elem : Word16 [num] ordered;
    }
    item def <Word32> Word32PField specializes Natural32Field, ExactlyPackedField{
        redefines Natural32Field::fieldSize redefines EPF::fieldSize = 4 [byte];
    }
	item def Words32 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines EPF::fieldSize redefines CompositeField::fieldSize = num * 32 [byte];
        redefines EPF::subFields redefines CompositeField::subFields = elem;
        item elem : Word32 [num] ordered;
    }
    item def <Word64> Word64PField specializes Natural64Field, ExactlyPackedField{
        redefines Natural64Field::fieldSize redefines EPF::fieldSize = 8 [byte];
    }
	item def Words64 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines EPF::fieldSize redefines CompositeField::fieldSize = num * 64 [byte];
        redefines EPF::subFields redefines CompositeField::subFields = elem;
        item elem : Word64 [num] ordered;
    }
    item def <Word128> Word128PField specializes Natural128Field, ExactlyPackedField{
        redefines Natural128Field::fieldSize redefines EPF::fieldSize = 16 [byte];
    }
	item def Words128 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines EPF::fieldSize redefines CompositeField::fieldSize = num * 128 [byte];
        redefines EPF::subFields redefines CompositeField::subFields = elem;
        item elem : Word128 [num] ordered;
    }

	// TODO Finish makngSigned Words defs
	
    item def <OctetSigned> OctetSignedPField specializes Integer8Field, ExactlyPackedField{
        redefines Integer8Field::fieldSize redefines EPF::fieldSize = 1 [byte];
    }
	item def OctetsSigned specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines EPF::fieldSize redefines CompositeField::fieldSize = num [byte];
        redefines EPF::subFields redefines CompositeField::subFields = elem;
        item elem : OctetSigned [num] ordered;
    }
    item def <Word16Signed> Word16SignedPField specializes Integer16Field, ExactlyPackedField{
        redefines Integer16Field::fieldSize redefines EPF::fieldSize = 2 [byte];
    }
	item def Words16Signed specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines EPF::fieldSize redefines CompositeField::fieldSize = num * 16 [byte];
        redefines EPF::subFields redefines CompositeField::subFields = elem;
        item elem : Word16Signed [num] ordered;
    }



    abstract item def FixedPointPField :> EPF {
        attribute delta {doc /* smallest spacing between values of the type being represented */}
        attribute small {doc /* smallest spacing between values actually stored...Value of least significant bit */}
        attribute rangeMin {doc /* minimum value of the type being represented */}
        attribute rangeMax {doc /* maximum value of the type being represented */}
        assert constraint checkRange { rangeMin <= rangeMax }
    }
    
    item def UFPPF :> FixedPointPField{
    	:>> value : Natural default 0;
    }
    
    item def SFPPF :> FixedPointPField {
    	item sign : SignBit; // TODO FIXME finish working out this new direction
    }
    item def UnsignedFixedPointPField :> ExactlyPackedField {
        :>> value : Natural default 0;
        attribute delta {doc /* smallest spacing between values of the type being represented */}
        attribute small {doc /* smallest spacing between values actually stored...Value of least significant bit */}
        attribute rangeMin {doc /* minimum value of the type being represented */}
        attribute rangeMax {doc /* maximum value of the type being represented */}
        assert constraint checkRange { rangeMin <= rangeMax }
    }
    
    enum def Sign :> Bit {
        enum POSITIVE = 0;
       	enum NEGATIVE = 1;
    }
	item def <SignBit> SignBitPField :> ExactlyPackedField {
		:>> value : Sign default Sign::POSITIVE;
	}
      
    abstract item def SignedFixedPointPField :> ExactlyPackedField {
        :>> subFields ordered = (sign, ufpf);
        item sign : SignBit;
        item ufpf : UnsignedFixedPointPField;
        assert constraint checkSize {fieldSize == ufpf.fieldSize + sign.fieldSize}
    }


// TODO add floating point representations    
 
}