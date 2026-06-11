/* 
 * This file © 2025-2026 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  
 
 package 'com.meadortech.LayeredComms' {
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
		 The purpose of com.meadortech.LayeredComms is to provide a framework & building blocks for 
		 SysML 2 models constructed to specify protocols, the layering of protocols, and the use of 
		 elements from those protocol-specification models in other models. Interoperability of 
		 communicating entities using these protocols and the layering of these protocols are key goals.

		 It very intentionally is informed strongly by the ISO OSI protocol definition and layering concepts
		 and brings a form of those concepts into an expression in SysML 2.

		 For example, protocol entities and all their aspects are key to describing protocols and their 
		 layering in OSI, so they are fundamental to the building blocks LayeredComms provides. As far as a 
		 LayeredComms protocol specification approach is concerned, for a system to conform to a protocol means 
		 that it logically provides at least one protocol entity for the protocol that meets what is defined for 
		 that protocol entity type as expressed with the LayredComms building blocks. Doing so does not specify 
		 the implementation within that system and does not even require a specific designed realization within 
		 that system. This is a common approach supported by the OSI and provided by LayeredComms package. It is 
		 well-understood and accepted for those working in the layered protocol stack world.

		 Those using this package are encouraged to become familiar with ISO OSI.
	  	 */    
	comment TODOs
	/* 
	 * * TODO - Review0001 Place extensive overview here
	 * * TODO - Review0001 How to refer to protocol specs? External ref facility coming (hpd)?
	 * * TODO - Review0001 Need to address broadcast and multicast interfaces, etc.
	 * * WITHDRAWN - Review0001 Make semantic metadata usages more specific to appropriate base type
	 * * TODO - Review0001 Make semantic metadata have base type of SysML::Type
	 * * TODO - Review0001 Make all use of user defined keywords also name SysML keywords (ex. part def)
	 */


	//
	// Protocol Entity Aspects
	//
	comment ProtocolEntityAspects about 
		ProtocolEntity,
		protocolEntities,
		_ProtocolEntity_
		/*
		 * Protocol Entity Aspects
		 */
    abstract part def ProtocolEntity {
    	doc	
    	/* 
    	 * Reference the OSI general model for protocol entities.
    	 */
        abstract #_PDU_Port_     part pduPorts    [1..*] ordered{
        	doc 
        	/*  
        	 *	*PDU Ports* are on the boundary of a protocol entity and represent the
	         *	well-defined points where the protocol entity sends and receives
	         *	Protocol Data Units (PDUs).
        	 */
        }
        abstract #_SAP_          part saps        [0..*] ordered{
        	doc
        	/*
        	 *	*Service Access Points*
        	 *	SAPs are on the boundary of a protocol entity and represent the
	         *	well-defined points where the protocol entity sends and receives
	         *	the protocol's Service Data Units (SDUs).
        	 *	
        	 */
        }
        abstract #_SAP_Client_   part sapClients  [0..*] ordered{
        	doc
        	/*
        	 *  Represents the procol entity's client side of the n-1 protocol's SAP
        	 */
        }
        abstract #_Protocol_Stm_ state protocolStm [1..*] ordered {
        	doc
        	/*
        	 * Each protocol entity has at least one state machine that governs
			 * its protocol-related operation.
        	 */
        }
        exhibit state peStm :> protocolStm{
        	doc
        	/*
        	 * The protocol state machine(s) exhibited by the protocol entity.
        	 */
        }
    }

	abstract part protocolEntities : ProtocolEntity[0..*] nonunique;
	
	metadata def <_ProtocolEntity_> ProtocolEntityMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = protocolEntities meta SysML::Type;
        protocolName : ScalarValues::String; 
	}


    //
    // PDU Aspects 
    //
    comment PDU_Aspects about 
    	PDU, protocolDataUnits, _PDU_,
    	PDUPort, pduPorts, _PDU_Port_,
    	PDULink, pduLinks, _PDU_Link_
    	/*
    	 * PDU Aspects
    	 */
        
    abstract item def <PDU> ProtocolDataUnit{
		doc 
			/* Protocol Data Units per OSI */

	}
    abstract item protocolDataUnits : ProtocolDataUnit [0..*] nonunique;
    
	metadata def <_PDU_> PDUMetadata :> Metaobjects::SemanticMetadata {
			
		:>> baseType = protocolDataUnits meta SysML::Type;
        protocolName : ScalarValues::String; 
	}

    abstract port def PDUPort{
		doc
			/* I/O point for the PDUs of the protocol */
        inout abstract #_PDU_ item io_pdu;
    }
    abstract port pduPorts : PDUPort [0..*] nonunique;

	metadata def <_PDU_Port_> PDUPortMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = pduPorts meta SysML::Type;
        protocolName : ScalarValues::String; 
	}

    abstract connection def PDULink {
		doc	
			/* An interface between two protocol entities of the same protocol. */
        end #_PDU_Port_ port a : PDUPort [1];
        end #_PDU_Port_ port b : PDUPort [1];
    }

    abstract connection pduLinks : PDULink[0..*] nonunique;

	metadata def <_PDU_Link_> PDULinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = pduLinks meta SysML::Type;
        protocolName : ScalarValues::String; 
	}

	//
	// Layered Relationships
	//
	comment Layered_Relationships about
		LayerMap, layeredMappings, _LayerMap_,
		depPDULink, depPDUPort,
		OverPDULink, overPDULinks, _Over_PDU_Link_,
		OverPDUPort, overPDUPorts, _Over_PDU_Port_
		/*
		 * Layered Relationships
		 */

	metadata def <depLayerMap> _DependsLayerMap_ {
    	doc
			 /*
			  * This dependency represents the fact that a given element
			  * in a layered interface stack has a cross-layer dependency on another
			  * element in some lower layer within a given context.
			  * 
			  * The depLayerMap does not restrict the mappedTo element to be within the n-1 layer;
			  * in other words, layers can be skipped -- or crossed over -- with the depLayerMap
			  * dependency.
			  * 
			  * depLayerMap is transitive, meaning if A=>B and B=>C then A=>C.
			  * However, M=>P and M=>N does not imply N=>P.
			  */
        annotatedElement : SysML::Dependency redefines annotatedElement; 
    }
	comment about LayerMap 
		/* * TODO - Review0001 Evaluate adding appropriate constraints about upper to lower "direction"
		 * - skipping might actually be allowed, so this is an optional idea in general
		 */
	
    connection def <LayerMap> LayeredMapping {
         doc 
	         /* Represents the fact that elements in a layered interface stack (mappedFrom) 
	          * is mapped to other elements (mappedTo) in some lower layer(s) within a given context.
	          * The LayerMap does not restrict the mappedTo element to be within the n-1 layer;
	          * in other words, layers can be skipped -- or crossed over -- with the LayerMap
	          * connection.
	          * 
	          * The ends are typed as Occurence because the layers may have elements
	          * of differing types that are relevant for the cross-layer mapping.
	          * 
	          * The semantics of LayerMap are that the mappedFrom end is related in some way
	          * with the element in the mappedTo end in the layered interface pattern.
	          * 
	          * LayerMap is transitive, meaning if A=>B and B=>C then A=>C.
	          * However, M=>P and M=>N does not imply N=>P.
	          * 
	          * Additional constraints may be needed to restrict to specific layers
	          */
    	end [1..*] ref mappedFrom : Occurrences::Occurrence;
    	end [1..*] ref mappedTo   : Occurrences::Occurrence;
    }
    
    abstract part layeredMappings : LayeredMapping [0..*];
	metadata def <_LayerMap_> LayerMapMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = layeredMappings meta SysML::Type;
	}



    metadata def <depPDULink> _DependsOnPDULink_ {
        doc /*
         * This dependency represents the fact that a given PDU
         * interface in a protocol stack directly depends on another
         * PDU interface at the next layer below in the protocol stack.
         */
        annotatedElement : SysML::Dependency redefines annotatedElement; 
    }
    
    comment about depPDUPort
    /* 	 * TODO - Review0001 Discussion underway as to efficacy
     *   * TODO - Review0001 Consider need for "encapsulated in" dependency
     *     - and/or connection relationship for this meaning
     *     - 
    */    
    
    metadata def <depPDUPort> _DependsOnPDUPort_ {
        doc /*
         * This dependency represents the fact that a given PDU
         * Port in a protocol stack directly depends on another
         * PDU Port at the next layer below in the protocol stack.
         */
        annotatedElement : SysML::Dependency redefines annotatedElement; 

		comment c1 about depPDUPort
			/* 	* TODO - Review0001 Discussion underway as to efficacy
			*   * TODO - Review0001 Consider need for "encapsulated in" dependency
			*     - and/or connection relationship for this meaning
			*/    
			
    }


    connection def OverPDULink {
         doc 
	         /* The Over connection represents the fact that a given PDU
	          * interface in a protocol stack (N) directly depends on another
	          * PDU interface at the protocol stack layer below it (N-1).
	          */
    	end #_PDU_Link_ connection upper : PDULink [1];
    	end #_PDU_Link_ connection lower : PDULink [1];
    }
    abstract part overPDULinks : OverPDULink [0..*];
	metadata def <_Over_PDU_Link_> OverPDULinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = overPDULinks meta SysML::Type;
	}
    
    connection def OverPDUPort {
         doc 
	         /* The OverPDUport connection represents the fact that a given PDU
	          * Port in a protocol stack directly depends on another
	          * PDU Port at the protocol stack layer below it. This connection
	          * type can be used to represent, for example, that the PDUs in the
	          * upper protocol for that port are encapsulated in the lower 
	          * protocol of the lower port.
	          */
    	end #_PDU_Port_ port upper : PDUPort [1];
    	end #_PDU_Port_ port lower : PDUPort [1];
    }
    abstract part overPDUPorts : OverPDUPort [0..*];
	metadata def <_Over_PDU_Port_> OverPDUPortMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = overPDUPorts meta SysML::Type;
	}
    


    
    //
    // SDU Aspects
    //
    // * TODO Review0001 - Consider adding SDU directional features on SAP/Client ports
    abstract item def <SDU> ServiceDataUnit{
		doc 
			/* Service Data Units of a protocol that are exchanged 
			 * with the client protocole entity in the layer above.
			 * See OSI for more. 
			 */
	}
    abstract item serviceDataUnits : ServiceDataUnit [0..*] nonunique;
	metadata def <_SDU_> SDUMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = serviceDataUnits meta SysML::Type;
        protocolName : ScalarValues::String; 
	}
    
    abstract port def <SAP> ServiceAccessPoint{
		doc 
			/* The protocol entity Service Access Point per OSI. */
	}
    abstract port serviceAccessPoints : ServiceAccessPoint [0..*] nonunique;
	metadata def <_SAP_> SAPMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = serviceAccessPoints meta SysML::Type;
        protocolName : ScalarValues::String; 
	}
    
    abstract port def <SAPClient> SAPClientPort{
		doc 
			/* The N protocol's client to the N-1 protocol's SAPs per OSI. */
	}
    port serviceAccessPointClients : SAPClientPort [0..*] nonunique;
	metadata def <_SAP_Client_> SAPClientMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = serviceAccessPointClients meta SysML::Type;
        protocolName : ScalarValues::String; 
	}


    abstract connection def SDULink {
		doc
			/* Interface between the N-1 and N protocol entities. */
        end #_SAP_Client_ port sapCl  : SAPClient [1];
        end #_SAP_        port sap    : SAP [1];
	}
	abstract connection sduLinks : SDULink [0..*] nonunique;
	metadata def <_SDU_Link_> SDULinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = sduLinks meta SysML::Type;
        protocolName : ScalarValues::String; 
	}
	
	//
	// Protocol State Machines
	//
	abstract state def ProtocolStateMachine{
		doc
			/* Base type for all protocol state machines. */
	}
	abstract state protocolStateMachines : ProtocolStateMachine [0..*] nonunique;
	metadata def <_Protocol_Stm_> ProtocolStmLinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = protocolStateMachines meta SysML::StateUsage;
        protocolName : ScalarValues::String; 
	}

    // Sets of PDU Links
     
    item def PDULinkSet {
		doc
			/* Convenience type to collect together sets of PDULinks. */
        ref #_PDU_Link_ members : PDULink [*]; 
    }
    
    //  metadata def <protocol> Protocol {
    //     doc 
    //     /*
    //      * Provides for indicating the protocol associated with annotatedElement.
    //      */
    //     annotatedElement : SysML::Definition redefines annotatedElement;
    //     protocolName : ScalarValues::String; 
    // }
	
    metadata def ProtocolPackage {
        annotatedElement : SysML::Package redefines annotatedElement;
        protocolName : ScalarValues::String; 
    }

	package ProtocolStacks {
		part def LayeredProtocol {
			doc
				/* A protocol that is layered with other protocols in a protocol stack.
				 *  
				 * 
				*/

	        attribute protocolName : ScalarValues::String; 			
		}

		abstract item layeredProtocols : LayeredProtocol [0..*] nonunique;
		metadata def <_LayeredProtocol_> LayeredProtocolMetadata :> Metaobjects::SemanticMetadata {
			:>> baseType = layeredProtocols meta SysML::Type;
		}

		connection def LayeredOn {
			doc
				/* The LayeredOn connection represents the fact that a given protocol is layered on top of another protocol in a protocol stack. */
			end upper : LayeredProtocol [1];
			end lower : LayeredProtocol [1];
		}

		part def ProtocolStack specializes LayeredProtocol {
			doc
				/* A protocol stack is a collection of protocols that are layered together. */
			part protocols : LayeredProtocol [1..*];
			
		}

	    port def ProtocolStackPort {
			doc
				/* A port for a protocol stack. */
			ref stack : ProtocolStack;
    	}

		interface def ProtocolStackInterface {
			part stack : ProtocolStack;
			end endA : ProtocolStackPort;
			end endB : ProtocolStackPort;
		}

		connection def ProtocolStackHConn {
			end endA : LayeredProtocol;
			end endB : LayeredProtocol;
		}

	}
 }