package 'com.meadortech.LCExperimental'{


	
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
	}

	
	package ExperimentalUse {

		package TransportProtocolBindings{
			#_Protocol_Binding_ def Transport_Over_Network {
				end #_Comms_Protocol_ upper : TransportProtocol::TransportCommsProtocol;
				end #_Comms_Protocol_ lower :  NetworkProtocol::NetworkCommsProtocol;
			}
		}
		// TODO add values to refs below	    
	    #_Comms_Protocol_ def TransportCommsProtocol {
	    	ref #_ProtocolEntity_   pes      : TransportProtocolEntity [1] redefines pes;
	    	ref #_PDU_              pdus     : TransportPDU                redefines pdus; 
	    	ref #_SDU_              sdus     : TransportSDU                redefines sdus;
	    	ref #_PDU_Link_         pduLinks : TransportLink               redefines pduLinks;
	    	ref #_SDU_Link_         sduLinks : TransportSDULink            redefines sduLinks;
//	    	ref #_Protocol_Binding_ carries [0]                            redefines carries;
//	    	ref #_Protocol_Binding_ carriedBy [1]                          redefines carriedBy;
	    }
	    


	}
}