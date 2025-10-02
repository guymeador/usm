/* 
 * This file © 2025 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  

 package 'com.meadortech.ExploringLayers'{
 	
 	package Layers {
	 	viewpoint def LayeredArchitectureViewpoint;
	    
	    metadata def <layer> Layer {
	    	doc 
	    		/*
	    		 * A layer is abstract and can never be instantiated.
	    		 * This is because a layer is a meta-concept relative to a user model.
	    		 * Anything can be mapped to one or more layers in a
	    		 * layered architecture.
	    		 * 
	    		 * Further, various layering approaches can be identified and be
	    		 * at play simultaneously in a user model, even for the same element
	    		 * or set of elements within the user model.
	    		 * 
	    		 * User model elements are mapped through meta-information.
	    		 */
	        annotatedElement : SysML::Definition redefines annotatedElement;
	        layerName : ScalarValues::String; 
	    }
 	}

 	package Comms_Layers {
 		viewpoint def LayeredProtocolStackViewpoint specializes Layers::LayeredArchitectureViewpoint;
 		
 		metadata def Comms_Layer :> Layers::Layer;
 	
		enum def CommsLayerName :> ScalarValues::String {
			L1 = "L1-PHY";
			L2 = "L2-Datalink";
			L3 = "L3-Network";
			L4 = "L4-Transport";
			L5 = "L5-Session";
			L6 = "L6-Presentation";
			L7 = "L7-Application";
		} 		
 		
 		metadata def Comms_Protocol {
			annotatedElement : SysML::Definition redefines annotatedElement;
			protocolName : ScalarValues::String;
 		}
 	}
 	
 	package TProtocol {
		
 		alias CL for Comms_Layers;
 		alias LC for 'com.meadortech.LayeredComms';

		enum def Protocol :> ScalarValues::String {
			@CL::Comms_Protocol{protocolName = TProtocol;}
			@CL::Comms_Layer   {layerName=CL::CommsLayerName::L4;}
			TProtocol = "TProtocol";
		} 		
		

 		#LC::_PDU_ def TPDU {
			@CL::Comms_Protocol{protocolName = Protocol::TProtocol;}
 		}
 		#LC::_SDU_ def TSDU {
			@CL::Comms_Protocol{protocolName = Protocol::TProtocol;}
 		}
 		#LC::_SAP_ def TSAP {
			@CL::Comms_Protocol{protocolName = Protocol::TProtocol;}
 		}
 		#LC::_PDU_Port_ def TPDU_Port {
			@CL::Comms_Protocol{protocolName = Protocol::TProtocol;}
 		}
 		#LC::_ProtocolEntity_ def TProtocol_Entity {
			@CL::Comms_Protocol{protocolName = Protocol::TProtocol;}
 		}
 		
 	}
 	
 }