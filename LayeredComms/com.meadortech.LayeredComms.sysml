/* 
 * This file © 2025 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  
 
package 'com.meadortech.LayeredComms' {
    doc 
        /* 
         * This package © 2025 by Guy Meador is licensed under Apache-2.0
         * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
         * SPDX-License-Identifier: Apache-2.0
         * 
         * See the comment Package_Overview for additional information
         */    
	comment Package_Overview about 'com.meadortech.LayeredComms'
	/* 
	 * * TODO - Review0001 Place extensive overview here
	 * * TODO - Review0001 How to refer to protocol specs? External ref facility coming (hpd)?
	 * * TODO - Review0001 Need to address broadcast and multicast interfaces, etc.
	 * * TODO - Review0001 Make semantic metadata usages more specific to appropriate base type
	 */
	alias DF for 'com.meadortech.DataFields'{ doc /* Provides bit-level representations */}
	/* * TODO Review0001 provide alias for new package having specific data types and data fields 
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
        abstract #_PDU_Port_     pduPorts    [1..*] ordered{
        	doc 
        	/*  
        	 *	*PDU Ports* are on the boundary of a protocol entity and represent the
	         *	well-defined points where the protocol entity sends and receives
	         *	the protocol's Protocol Data Units.
        	 */
        }
        abstract #_SAP_          saps        [0..*] ordered{
        	doc
        	/*
        	 *	*Service Access Points*
        	 *	SAPs are on the boundary of a protocol entity and represent the
	         *	well-defined points where the protocol entity sends and receives
	         *	the protocol's Service Data Units.
        	 *	
        	 */
        }
        abstract #_SAP_Client_   sapClients  [0..*] ordered{
        	doc
        	/*
        	 *  Represents the procol entity's client side of the n-1 protocol
        	 */
        }
        abstract #_Protocol_Stm_ protocolStm [1..*]{
        	doc
        	/*
        	 * TODO provide description 
        	 */
        }
        exhibit state peStm :> protocolStm{
        	doc
        	/*
        	 * TODO provide description
        	 */
        }
    }

	part protocolEntities : ProtocolEntity[0..*] nonunique;
	
	metadata def <_ProtocolEntity_> ProtocolEntityMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = protocolEntities meta SysML::Usage;
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
        
    abstract item def <PDU> ProtocolDataUnit;
    
    item protocolDataUnits : ProtocolDataUnit [0..*] nonunique;
    
	metadata def <_PDU_> PDUMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = protocolDataUnits meta SysML::Usage;
        protocolName : ScalarValues::String; 
	}

    abstract port def PDUPort{
        inout abstract #_PDU_ io_pdu;
    }
    port pduPorts : PDUPort [0..*] nonunique;

	metadata def <_PDU_Port_> PDUPortMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = pduPorts meta SysML::Usage;
        protocolName : ScalarValues::String; 
	}

    abstract interface def PDULink {
        end a : PDUPort [1];
        end b : PDUPort [1];
    }

    part pduLinks : PDULink[0..*] nonunique;

	metadata def <_PDU_Link_> PDULinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = pduLinks meta SysML::Usage;
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
    
    part layeredMappings : LayeredMapping [0..*];
	metadata def <_LayerMap_> LayerMapMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = layeredMappings meta SysML::Usage;
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
    }


    connection def OverPDULink {
         doc 
	         /* The Over connection represents the fact that a given PDU
	          * interface in a protocol stack directly depends on another
	          * PDU interface at the protocol stack layer below it.
	          */
    	end upper : PDULink [1];
    	end lower : PDULink [1];
    }
    part overPDULinks : OverPDULink [0..*];
	metadata def <_Over_PDU_Link_> OverPDULinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = overPDULinks meta SysML::Usage;
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
    	end upper : PDUPort [1];
    	end lower : PDUPort [1];
    }
    part overPDUPorts : OverPDUPort [0..*];
	metadata def <_Over_PDU_Port_> OverPDUPortMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = overPDUPorts meta SysML::Usage;
	}
    


    
    //
    // SDU Aspects
    //
    // * TODO Review0001 - Consider adding SDU directional features on SAP/Client ports
    abstract item def <SDU> ServiceDataUnit{}
    item serviceDataUnits : ServiceDataUnit [0..*] nonunique;
	metadata def <_SDU_> SDUMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = serviceDataUnits meta SysML::Usage;
        protocolName : ScalarValues::String; 
	}
    
    abstract port def <SAP> ServiceAccessPoint{}
    port serviceAccessPoints : ServiceAccessPoint [0..*] nonunique;
	metadata def <_SAP_> SAPMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = serviceAccessPoints meta SysML::Usage;
        protocolName : ScalarValues::String; 
	}
    
    abstract port def <SAPClient> SAPClientPort{}
    port serviceAccessPointClients : SAPClientPort [0..*] nonunique;
	metadata def <_SAP_Client_> SAPClientMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = serviceAccessPointClients meta SysML::Usage;
        protocolName : ScalarValues::String; 
	}


    abstract interface def SDULink {
        end sapCl  : SAPClient [1];
        end sap    : SAP [1];
	}
	part sduLinks : SDULink [0..*] nonunique;
	metadata def <_SDU_Link_> SDULinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = sduLinks meta SysML::InterfaceUsage;
        protocolName : ScalarValues::String; 
	}
	
	//
	// Protocol State Machines
	//
	abstract state def ProtocolStateMachine;
	state protocolStateMachines : ProtocolStateMachine [0..*] nonunique;
	metadata def <_Protocol_Stm_> ProtocolStmLinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = protocolStateMachines meta SysML::StateUsage;
        protocolName : ScalarValues::String; 
	}
	
	
	// * TODO Review0001: Clearly mark science experiment for protocol and protocol binding reification in initial release
	//   - there are difficulties between abstract definition of a protocol and
	//     reification in an implementation (or model of that)
	// Protocol Binding - Experimental Approach
	//
	// * TODO Review0001 The current approach needs some re-work
	// - The representation below really applies to a single set of
	//   PEs and their relationships, not the protocol in general.
	// - Other approaches that have more of a meta-level set of
	//   relationships are likely more appropriate
	//
	connection def ProtocolBinding {
		end [*] #_Comms_Protocol_ upper : CommsProtocol;
		end [*] #_Comms_Protocol_ lower : CommsProtocol;
	}
	part protocolBindings : ProtocolBinding [0..*];
	metadata def <_Protocol_Binding_> ProtocolBindingMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = protocolBindings meta SysML::Usage;
	}

	abstract part def <CommsProtocol> CommunicationsProtocol {
		ref #_ProtocolEntity_      pes         [1..*];
		ref #_PDU_                 pdus        [1..*];
		ref #_SDU_                 sdus        [1..*];
		ref #_PDU_Link_            pduLinks    [1..*];
		ref #_SDU_Link_            sduLinks    [1..*];
		ref #_Protocol_Binding_    carries     [0..*]; 
		ref #_Protocol_Binding_    carriedBy   [0..*]; 
	}
	part commsProtocols : CommunicationsProtocol [0..*];
	metadata def <_Comms_Protocol_> CommsProtocolLinkMetadata :> Metaobjects::SemanticMetadata {
		:>> baseType = commsProtocols meta SysML::Usage;
        protocolName : ScalarValues::String; 

	package 'Alternate approach to CommsProtocol'{        
    //    
    // Alternate Approach TBD, which one to use, if at all?
    //
    	//abstract part def CommsProto {}
    	abstract connection def CommsProtocol_to_Entity {
    		end [0..*] #_Comms_Protocol_ protocol : CommsProtocol;
    		end [1..*] #_ProtocolEntity_ pe       : ProtocolEntity;
    	}
    	
		package MyProtocol {
			
	    	abstract #_ProtocolEntity_ def MyProtoEntity;
	    	#_ProtocolEntity_ def Sender :> MyProtoEntity;
	    	#_ProtocolEntity_ def Receiver :> MyProtoEntity;

	    	#_Comms_Protocol_ def MyProto :> CommsProtocol{

				ref #_ProtocolEntity_ pes  : MyProtoEntity redefines pes;
				ref #_ProtocolEntity_ spe  : Sender [0..1] subsets pes;
				ref #_ProtocolEntity_ rpes : Receiver [*] subsets pes;
				
				comment about MyProto /* other refs omitted for this example*/
	    	}

	    	connection def MyProto_to_Sender :> CommsProtocol_to_Entity {
	    		end [1] #_Comms_Protocol_ protocol : MyProto redefines protocol;
	    		end [1] #_ProtocolEntity_ pe       : Sender  redefines pe;
	    	}
	    	connection def MyProto_to_Receiver :> CommsProtocol_to_Entity {
	    		end [1   ] ref protocol : MyProto redefines protocol;
	    		end [1..*] ref pe : Receiver redefines pe;
	    	}
		}    	

		#_ProtocolEntity_ s1 : MyProtocol::Sender;    	
		#_ProtocolEntity_ r1 : MyProtocol::Receiver;    	
		#_ProtocolEntity_ r2 : MyProtocol::Receiver;    	
		#_ProtocolEntity_ r3 : MyProtocol::Receiver;    	

		#_Comms_Protocol_ prtcl01 : MyProtocol::MyProto{
			connection s_1 : MyProtocol::MyProto_to_Sender   connect prtcl01 to s1;
			connection r_1 : MyProtocol::MyProto_to_Receiver connect prtcl01 to r1;    	
			connection r_2 : MyProtocol::MyProto_to_Receiver connect prtcl01 to r2;    	
			connection r_3 : MyProtocol::MyProto_to_Receiver connect prtcl01 to r3; 
			
			:>> spe = s1;
			:>> rpes = (r1, r2, r3);  	
		}
	}
	
    metadata def <protocol> Protocol {
        doc 
        /*
         * Provides for indicating the protocol associated with annotatedElement.
         */
        annotatedElement : SysML::Definition redefines annotatedElement;
        protocolName : ScalarValues::String; 
    }
	
    metadata def ProtocolPackage {
        annotatedElement : SysML::Package redefines annotatedElement;
        protocolName : ScalarValues::String; 
    }
	

    // Sets of PDU Links
     
    item def PDULinkSet {
        ref members : PDULink [*]; 
    }
    
 }
 
 }