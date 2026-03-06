# Useful System Models (USM)

Here is a collection of open system models and system libraries that will, hopefully, be (or become)
useful to others.

The state of the contents of this collection is very *alpha* at this point.

It is a beginning.

## Content

- DataFields - Libraries for modeling information/data with or without bit layout representation
    - com.meadortech.Datafields.sysml - Base library
- LayeredComms - Library with building blocks for layered communications stack modeling inspired by ISO OSI
    - com.meadortech.LayeredComms.sysml - Base Library for protocol definition, layering & use
    - com.meadortech.DFScalarValues.sysml - Representation of common scalar data types
- examples - Basic examples of using the above libraries
    - Simple DataField/DFScalarValues examples
    - Sketch of toy layered protocol definition and use
    

## Why and What of these Libraries and Examples?
### Why
Exploration
- What ways might there be of representing data and layered protocols in SysML 2?
- Applied learnings through experience with Layered Interface Pattern Example
- Libraries for these things are likely useful for specifications leading to interoperability

### What
#### DataFields
Goal: Specify data formats in SysML 2

Viewpoint
- Info/Data Communications & Storage

Data-at-rest
- Memory / shared memory
- Other storage media (ex. files)

Data-in-motion (comm. protocols)
- Protocol Data Units (PDU)
- Service Data Units (SDU)

Multiple Aspects
- Functional..Logical..Physical
- Layered Coding
- Abstract to Concrete

Needs
- Audience: SE, Comp.E, SwE/CS, EE
- Concise/parsimonious
- Sufficient for interoperability
- “SysPhys for Information”

Building blocks
- Bit – DataField with Natural range 0..1
- bit – a unit of info storage capacity
- Uniform/direct expression of storage
    - size , indexing/offsets, used/unused, etc.
- Structure and meaning
    - Typed values, numeric subtypes & bases
    - Composite structures

##### More on DataFields

The storage of subfields does not overlap with each other.

Fields may be packed (isPacked=true), meaning they have
a definite fieldSize that is at least minSizePacked.

If a field is packed, then all of its subfields must also be packed.

SubFields may be positioned at non-overlapping definite offsets and extents
within the field's storage. All subFields of a packed field are packed as well.

The logical ordering of subFields and the ordering of the storage of subFields
within the enclosing field's storage are the same.

Bit ordering within a field's storage is 'Big Endian' TBD need to refine this def

The area of the field's storage associated with the value may be smaller than
the size of the field. This area may be optionally defined by the offset
attributes fieldInternalOffset and fieldInternalLastOffset which are offsets
referenced from the lowest bit index value for the field's storage.


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


#### DFScalarValues 

New formulation of defined data types built using DataFields.

Includes a bit-level representation for the modeled data types:
- Bit
- Octet
- OctetSigned
- BitMappedOctet
- Word16
- BitMappedWord16
- Integer16
- ... and more

More data types need to be added. It is a beginning.

#### LayeredComms

Provides ISO OSI-like building blocks for modeling protocols, their layering, and use.

Some of what is defined in the `com.meadortech.LayeredComms.sysml` library includes:

- ProtocolEntity
- Protocol_Stm
- PDU
- SDU
- PDU_Port
- SAP
- PDU_Link
- SAP_Link
- ...more

To support the modeling of layered protocol stacks, several facilities are available:
- SAP_Links between protocol entities on the same host
- Several dependency and connection definitions are available to express dependencies
and mappings from protocol elements in a higher level protocol to elements in
lower level protocol(s). For example, expressing TCP PDU link is over an IP PDU link.

#### Bit Numbering

- Big Endian bit numbering for now
- Bit numbering is zero-based
- Collections in SysML are 1-based indexing
- Convenience conversion support provided as a calc def

#### Element IDs and Library Versioning

USM takes a "textual notation - first" approach using `.sysml` files.

As such, it is not encumbered by the unnecessary constraint to assign and track element IDs from any particular
"authoritative" SysML 2 repository. 

Releases of USM (including the `.sysml` files within it) have semantic version numbers.

At present, a single semantic version number is assigned to the entire USM collection. In the future, individual
libraries will carry separate semantic versioning.

#### `.kpar` distribution

TBD

## With Appreciation
### Initial Alpha 0.0.1 Release

Thank you to the OMG System Modeling Community User WG’s Layered Interface Pattern subgroup members listed below. 
Your perspectives, wise counsel, feedback, advice, review, discussion, and patience have made this work all the better!

- Sanford Friedenthal
- Hans Peter de Koning
- Andrew Muxen
- Austin Roberts
- Peter Shames

Separate feedback was also received from others listed here. Thank you!:

- Vince Molnar
- Juozas Vaicenavicius
- Simas Vaitekicius

## Other Resources

- 2015-2016 Original JPL models and papers
    - Peter M. Shames, Marc A. Sarrel, Sanford Friedenthal
        - http://www.omgsysml.org/A_modeling_pattern_for_layered_system_interfaces-INCOSE%20IS15_presentation-sarrel-shames.pdf 
        - http://www.omgsysml.org/A_modeling_pattern_for_layered_system_interfaces-INCOSE%20IS15_paper-sarrel-shames.pdf 
        - http://www.omgsysml.org/INCOSE_IS_2016_paper_Application-of-a-Layered-Interface-Modeling-Pattern.pdf 

- OMG System Modeling Community
    - Users Working Group
        - Layered Interface Pattern Working Group
            - Advanced the examples from the above papers using SysML 2


## Copyright and Distribution License
Unless otherwise stated for specific files or directories, the following copyright and distribution license
applies to the contents of the USM collection.

See the NOTICE file for further notices pertaining to this work.

See the LICENSE file for further information about the distribution licenses that apply to this work.

### README.md
SPDX-License-Identifier: CC-BY-4.0

SPDX-FileCopyrightText: Copyright 2026 Guy Meador

SPDX-FileType: DOCUMENTATION

### Any SysML textual or graphical representations
For any SysML textual or graphical representations in the collection...

SPDX-License-Identifier: Apache-2.0

SPDX-FileCopyrightText: Copyright 2025-2026 Guy Meador

SPDX-FileType: SysML
