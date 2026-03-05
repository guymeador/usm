// This file © 2025-2026 by Guy Meador is licensed under Apache-2.0
// # To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
// SPDX-License-Identifier: Apache-2.0



library package 'com.meadortech.DataFields' {

    doc 
        /* 
         * This package © 2025 by Guy Meador is licensed under Apache-2.0
         * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
         * SPDX-License-Identifier: Apache-2.0
         */    
        
    private import SI::**; // for def of bit as a unit of storage
    private import ScalarValues::**;
    private import SequenceFunctions::*;
    private import NumericalFunctions::*;
    private import SI::**;
    
    
    
    abstract item def Field{
        doc
            /* 
             * Field classifies data type usages that may have a value, may consume
             * storage capacity (conventionally measured in bits), and may have
             * sub-fields whose storage are wholly contained within the Field's storage.
             */
        comment about Field
            /* 
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
        // assert constraint checkPackedHasMinPackedSize  {isPacked implies notEmpty(minSizePacked)}
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
        
        item subFields : Field[*] ordered;
        
        // TODO Add automatic setting of subfield superfield ref, index and offsets        
        
    }
    
    abstract item def PackedField specializes Field{
        :>> isPacked = true;
    }
    
    abstract item def CompositeField specializes Field{
        :>> subFields : Field[1..*] ordered;
        derived attribute redefines fieldSize default := sum(subFields.fieldSize); 
    }
    
    abstract item def PackedCompositeField specializes CompositeField, PackedField{
        doc
            /* 
             * All subfields are adjacent
             * */
             
        redefines subFields : PackedField [1..*] ordered;
        
        assert constraint checkPackedCompositeFieldSize{
            fieldSize == sum(subFields.fieldSize)
        }
        
    }
    
    item def <EPF> ExactlyPackedField :> PackedField {
    	doc /* 
             * General form of a field where actual, min, and max size are the same 
             * EPF is the main type to use from this package.
             */
        redefines fieldSize default 1 [bit];
        redefines minSizePacked = fieldSize;
        redefines maxFieldSize = fieldSize;
    }
    
}
       

