// This file © 2025 by Guy Meador is licensed under Apache-2.0
// # To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
// SPDX-License-Identifier: Apache-2.0


//*
 * Review0001
 * 
 * * TODO Review0001 Refactor so that another package or packages have the specific datatypes and associated data fields
 * * TODO Review0001 Ensure all needed doc comments are in place
 */
package 'com.meadortech.DataFields' {

    doc 
        /* 
         * This package © 2025 by Guy Meador is licensed under Apache-2.0
         * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
         * SPDX-License-Identifier: Apache-2.0
         */    
        
    public import SI::**; 
        // for def of bit as a unit of storage
    private import ScalarValues::**;
    private import SequenceFunctions::*;
    private import NumericalFunctions::*;
    private import SI::**;
    
    
    
    abstract item def Field{
//      The following doc is commented out so that the PlantUML rendering in Eclipse
//      does not take up lots of space on the diagrams
//
//        doc
            //* 
             * Field classifies data type usages that may have a value, may consume
             * storage capacity (conventionally measured in bits), and may have
             * sub-fields whose storage are wholly contained within the Field's storage.
             * 
             * The storage of subfields does not overlap with each other.
             * 
             * Fields may be packed (isPacked=true), meaning they have
             * a definite fieldSize that is at least minSizePacked.
             * 
             * If a field is packed, then all of its subfields must also be packed.
             * 
             * SubFields may be positioned at non-overlapping definite offsets and extents
             * within the field's storage. All subFields of a packed field are packed as well.
             * 
             * The logical ordering of subFields and the ordering of the storage of subFields
             * within the enclosing field's storage are the same.
             * 
             * Bit ordering within a field's storage is 'Big Endian' TBD need to refine this def
             * 
             * The area of the field's storage associated with the value may be smaller than
             * the size of the field. This area may be optionally defined by the offset
             * attributes fieldInternalOffset and fieldInternalLastOffset which are offsets
             * referenced from the lowest bit index value for the field's storage.
             * 
             * ┌───────────────────────────────────────────────┐    
             * │          Bit Array Model for Storage          │    
             * └───────────────────────────────────────────────┘    
             * ┌───────────────────────────────────────────────┐    
             * │                         1111111111222222222233│    
             * │  Bit Offset   01234567890123456789012345678901│    
             * │              ┌────────────────────────────────┤    
             * │             0│A.........B.....................│    
             * │            32│................................│    
             * │            64│C...............................│    
             * │            96│...............................D│    
             * └──────────────┴────────────────────────────────┘    
             *                                                      
             *                                                      
             *  StorageSize = 128 bit                        
             *  Bit Offsets                                         
             *  -----------                                         
             *  A =  0                                              
             *  B = 10                                              
             *  C = 64                                              
             *  D = 127                                             
             * 
             * 
 ┌───────────────────────────────┐           
 │    Field Storage Example 1    │           
 └───────────────────────────────┘           
 ┌───────────────────────────────┐           
 │                         111111│           
 │  Bit Offset   0123456789012345│           
 │              ┌────────────────┤           
 │             0│........VVVVVVVV│           
 └──────────────┴────────▲──────▲┘           
                         │      │            
  ┌──────────────────────┴─┐    │            
  │fieldInternalOffset = 8 │    │            
  └────────────────────────┘    │            
         ┌──────────────────────┴─────┐      
         │fieldInternalLastOffset = 15│      
         └────────────────────────────┘      
                                             
  VVVVVVVV represents bit indexes            
  associated with the field value            
                                             
  Other Field Attributes                     
  ----------------------                     
  fieldSize = 16 [bit]                       
  isPacked = true                            
  minSizePacked = 8 [bit]                    
                                             
  Note: Unused storage at index values 0..7  
                                             
                                             
                                             
  ┌───────────────────────────────┐          
  │    Field Storage Example 2    │          
  └───────────────────────────────┘          
  ┌───────────────────────┐                  
  │                       │                  
  │  Bit Offset   01234567│                  
  │              ┌────────┤                  
  │             0│VVVVVVVV│                  
  └──────────────┴▲──────▲┘                  
                  │      └────┐              
   ┌──────────────┴─────────┐ │              
   │fieldInternalOffset = 0 │ │              
   └────────────────────────┘ │              
          ┌───────────────────┴────────┐     
          │fieldInternalLastOffset = 7 │     
          └────────────────────────────┘     
                                             
   VVVVVVVV represents bit indexes           
   associated with the field value           
                                             
   Other Field Attributes                    
   ----------------------                    
   fieldSize = 8 [bit]                       
   isPacked = true                           
   minSizePacked = 8 [bit]                   
                                             
   Note: No unused storage                   
                                             
             * 
             */
             
        
//// Begin Field Attributes
        
        attribute value [0..1]{
            doc 
                /* Represents the data value for the field:
                 * - Intended to be redefined in the non-abstract specialization of Field.
                 * - Fields with an empty value can be used to represent storage capacity
                 *   without defining a specific idea of the value being stored; 
                 *   they can also be used to collect together subFields.
                 * - Composite fields (see below) may or may not have a value depending on 
                 *   the need.
                 */
        }
        attribute fieldSize : StorageCapacityValue [0..1]{
            doc
                /* Represents the storage size of the field (nominally expressed in units of bit
                 * as defined in the SI package): 
                 * - An empty fieldSize indicates no field size is specified.
                 * - A zero fieldSize indicates the field does not take up storage, which is illegal.
                 * - If the the Field isPacked then fieldSize must have a value
                 */    

            assert constraint checkExtantFieldSizeIsNonZero{ 
                notEmpty(fieldSize)  implies fieldSize > 0 [bit]
            }
        }
        
        attribute maxFieldSize : StorageCapacityValue [0..1]{
            doc
                /* Represents the maximum size the field may have in any context.
                 * - An empty maxFieldSize indicates no size is specified.
                 * - A zero maxFieldSize indicates the field does not take up storage, which is illegal.
                 * - If the Field isPacked then maxFieldSize may or may not have a value.
                 */

            assert constraint checkExtantMaxFieldSizeIsNonZero{ 
                notEmpty(maxFieldSize)  implies maxFieldSize > 0 [bit]
            }
                 
        }

        //
        // Packing
        //
        
        attribute isPacked : Boolean default := false{
            doc 
            /* Indicates if the representation of the field within storage
             * is specified with regard to actual fieldSize and possibly minimum field size,
             */
        }

        attribute minSizePacked : StorageCapacityValue [0..1] {
            doc /* The minimum field size in storage units of bits necessary for the field */
        }
            
        attribute <fldIntOfs> fieldInternalOffset : StorageCapacityValue [1] default 0 [bit]{            
            doc /* Bit offset within the field's storage for the first bit associated with the value */
        }
        
        attribute <fldIntLastOfs> fieldInternalLastOffset : StorageCapacityValue [0..1]{
            doc
                /* Bit offset within the field's storage for the last bit associated with the value.
                 * 
                 */
        }
        assert constraint CheckFldIntLastOfs {
            notEmpty (fldIntLastOfs)
                implies 
                    notEmpty (fldIntOfs)
                    and fldIntOfs <= fldIntLastOfs
                    
        }

        assert constraint checkPackedHasDefiniteSize   {isPacked implies notEmpty(fieldSize)}
        //assert constraint checkPackedHasMinPackedSize  {isPacked             implies notEmpty(minSizePacked)}
        // assert constraint checkExtantValueAndSizeAreExact
//        assert constraint checkExtantValueAndSizeIsCompatible{
//            notEmpty(value) and notEmpty(fieldSize)
//            implies
//            fieldSize >= (...bits required to store value...)
//        }

        //
        // As a subfield
        //
        // Time will tell if these are truly needed for specifying composite data fields
        // or if an approach that stores the information in the superField is more appropriate
        // or if these are not needed at all
        
        ref item <encField> enclosingField : Field [0..1] {
            doc
                /* The field for which this field is a subField.
                 * e.g. this field's outer, containing field (if any)
                 */
        }
        
        attribute <encFldIdx> enclosingFieldSubfieldIndex : Natural [0..1] {
            doc
                /* The enclosing field's index value for this field within the enclosing
                 * field's ordered collection of subFields.
                 */
        }
        
        attribute <encOffset> enclosingStorageOffset : StorageCapacityValue [0..1]{
            doc
                /* The offset of the begining of this field's storage
                 * within the enclosing field's storage.
                 */
        }
        
        
        //
        // With Sub Fields
        //
        
        item subFields : Field[*] ordered nonunique;
        
        // TODO Add automatic setting of subfield superfield ref, index and offsets        
        
    }
    
    abstract item def PackedField specializes Field{
        :>> isPacked = true;
    }
    
    abstract item def CompositeField specializes Field{
        :>> subFields : Field[1..*] ordered nonunique;
        derived attribute redefines fieldSize default := sum(subFields.fieldSize); 
    }
    
    abstract item def PackedCompositeField specializes CompositeField, PackedField{
        doc
            /* 
             * All subfields are adjacent
             * */
             
        redefines subFields : PackedField [1..*] ordered nonunique;
        
        assert constraint checkPackedCompositeFieldSize{
            fieldSize == sum(subFields.fieldSize)
        }
        
    }
    
    item def <EPF> ExactlyPackedField :> PackedField {
    	doc /* General form of a field where actual, min, and max size are the same */
        redefines fieldSize default 1 [bit];
        redefines minSizePacked = fieldSize;
        redefines maxFieldSize = fieldSize;
    }
    
    // Numeric sub-types particularly useful but not defined in standard packages

    attribute def Bit :> Natural { 
    doc 
        /* A fundamental definition of the range of a classical bit = 0..1 */
    
    assert constraint checkBitRange {0 <= that and that <=1}
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
        redefines fieldSize = 1 [bit];
        
    }
    // TODO Make elem's encOffset be bound to correct value for each of thes "plural" fields
	item def BinaryDigits specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num [bit];
        redefines Field::subFields = (elem);
        item elem : BinaryDigit [num] ordered;
    }
	item def <Word5> Word5PField :> Natural5Field, ExactlyPackedField{
		redefines fieldSize = 5 [bit];
	}
    item def <Octet> OctetPField specializes Natural8Field, ExactlyPackedField{
	    redefines fieldSize = 1 [byte];
    }
	item def Octets specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num [byte];
        redefines Field::subFields = (elem);
        item elem : Octet [num] ordered;
    }
    item def <Word16> Word16PField specializes Natural16Field, ExactlyPackedField{
        redefines fieldSize = 2 [byte];
    }
	item def Words16 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num * 16 [byte];
        redefines Field::subFields = (elem);
        item elem : Word16 [num] ordered;
    }
    item def <Word32> Word32PField specializes Natural32Field, ExactlyPackedField{
        redefines fieldSize = 4 [byte];
    }
	item def Words32 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num * 32 [byte];
        redefines Field::subFields = (elem);
        item elem : Word32 [num] ordered;
    }
    item def <Word64> Word64PField specializes Natural64Field, ExactlyPackedField{
        redefines fieldSize = 8 [byte];
    }
	item def Words64 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num * 64 [byte];
        redefines Field::subFields = (elem);
        item elem : Word64 [num] ordered;
    }
    item def <Word128> Word128PField specializes Natural128Field, ExactlyPackedField{
        redefines fieldSize = 16 [byte];
    }
	item def Words128 specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num * 128 [byte];
        redefines Field::subFields = (elem);
        item elem : Word128 [num] ordered;
    }

	// TODO Finish makngSigned Words defs
	
    item def <OctetSigned> OctetSignedPField specializes Integer8Field, ExactlyPackedField{
	    redefines fieldSize = 1 [byte];
    }
	item def OctetsSigned specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num [byte];
        redefines Field::subFields = (elem);
        item elem : OctetSigned [num] ordered;
    }
    item def <Word16Signed> Word16SignedPField specializes Integer16Field, ExactlyPackedField{
        redefines fieldSize = 2 [byte];
    }
	item def Words16Signed specializes EPF, CompositeField{
        attribute num : Natural default 1;
        redefines Field::fieldSize = num * 16 [byte];
        redefines Field::subFields = (elem);
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